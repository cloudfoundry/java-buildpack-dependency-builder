/*
 * Copyright 2017-2019 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package repository

import (
	"fmt"
	"github.com/Masterminds/semver"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"io/ioutil"
	"path"
	"path/filepath"
	"reflect"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
	"resources/out"
	"strings"
)

var (
	checkPattern = internal.Pattern{Regexp: regexp.MustCompile("^([\\d]+)\\.([\\d]+)\\.([\\d]+)_?(.*)$")}
)

type Repository struct {
	Source     source           `json:"source"`
	Version    internal.Version `json:"version"`
	Parameters parameters       `json:"params"`
}

type parameters struct {
	File                     string `json:"file"`
	DownloadDomain           string `json:"download_domain"`
	CloudFrontDistributionId string `json:"cloudfront_distribution_id"`
}

type source struct {
	AccessKeyId     string `json:"access_key_id"`
	SecretAccessKey string `json:"secret_access_key"`

	Bucket         string           `json:"bucket"`
	Path           string           `json:"path"`
	URI            string           `json:"uri"`
	VersionPattern internal.Pattern `json:"version_pattern"`
}

func (r Repository) Check() (check.Result, error) {
	s, err := r.session()
	if err != nil {
		return check.Result{}, err
	}

	i := index{
		session: s,
		bucket:  r.Source.Bucket,
		path:    r.Source.Path,
		uri:     r.Source.URI,
	}
	if err := i.load(); err != nil {
		return check.Result{}, err
	}

	result := check.Result{Since: r.Version}

	for v, _ := range i.contents {
		if err := checkPattern.IfMatches(v, func(g []string) error {
			ref := fmt.Sprintf("%s.%s.%s", g[1], g[2], g[3])
			if g[4] != "" {
				ref = fmt.Sprintf("%s-%s", ref, g[4])
			}

			if reflect.DeepEqual(r.Source.VersionPattern, internal.Pattern{}) || r.Source.VersionPattern.MatchString(ref) {
				result.Add(internal.Version{Ref: ref})
			}

			return nil
		}); err != nil {
			return check.Result{}, err
		}
	}

	return result, nil
}

func (r Repository) In(destination string) (in.Result, error) {
	s, err := r.session()
	if err != nil {
		return in.Result{}, err
	}

	i := index{
		session: s,
		bucket:  r.Source.Bucket,
		path:    r.Source.Path,
		uri:     r.Source.URI,
	}
	if err := i.load(); err != nil {
		return in.Result{}, err
	}

	uri, err := r.lookupUri(i)
	if err != nil {
		return in.Result{}, err
	}

	sha256, err := in.Artifact{
		Name:        path.Base(uri),
		Version:     r.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: r.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (r Repository) Out(source string) (out.Result, error) {
	s, err := r.session()
	if err != nil {
		return out.Result{}, err
	}

	file, err := r.file(source)
	if err != nil {
		return out.Result{}, err
	}

	a := artifact{
		session: s,
		bucket:  r.Source.Bucket,
		path:    r.Source.Path,
		file:    file,
	}
	sha256, err := a.Upload()
	if err != nil {
		return out.Result{}, err
	}

	i := index{
		session: s,
		bucket:  r.Source.Bucket,
		path:    r.Source.Path,
	}
	if err := i.load(); err != nil {
		return out.Result{}, err
	}

	v, err := r.readVersion(file)
	if err != nil {
		return out.Result{}, err
	}
	semver, err := v.AsSemver()
	if err != nil {
		return out.Result{}, err
	}
	uri, err := r.createUri(file)
	if err != nil {
		return out.Result{}, err
	}
	i.contents[r.version(semver)] = uri

	if err := i.save(); err != nil {
		return out.Result{}, err
	}

	d := distribution{
		session:        s,
		distributionId: r.Parameters.CloudFrontDistributionId,
		paths:          []string{a.Key(), i.Key()},
	}
	if err := d.invalidate(); err != nil {
		return out.Result{}, err
	}

	return out.Result{
		Version: v,
		Metadata: []out.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (r Repository) createUri(file string) (string, error) {
	if r.Parameters.DownloadDomain == "" {
		return "", fmt.Errorf("download-comain must be specified")
	}

	if r.Source.Path == "" {
		return "", fmt.Errorf("path must be specified")
	}

	return fmt.Sprintf("https://%s%s/%s", r.Parameters.DownloadDomain, r.Source.Path, path.Base(file)), nil
}

func (r Repository) file(source string) (string, error) {
	files, err := filepath.Glob(filepath.Join(source, r.Parameters.File))
	if err != nil {
		return "", err
	}

	if len(files) != 1 {
		return "", fmt.Errorf("%s did not match exactly one file: %s", r.Parameters.File, files)
	}

	return files[0], nil
}

func (r Repository) lookupUri(index index) (string, error) {
	s, err := r.Version.AsSemver()
	if err != nil {
		return "", err
	}

	v := r.version(s)
	u, ok := index.contents[v]
	if !ok {
		return "", fmt.Errorf("%s not available", v)
	}

	return u, nil
}

func (r Repository) session() (*session.Session, error) {
	var c *credentials.Credentials

	if r.Source.AccessKeyId == "" {
		c = credentials.AnonymousCredentials
	} else {
		c = credentials.NewStaticCredentials(r.Source.AccessKeyId, r.Source.SecretAccessKey, "")
	}

	return session.NewSession(&aws.Config{
		Credentials: c,
		Region:      aws.String("us-east-1"),
	})
}

func (Repository) readVersion(file string) (internal.Version, error) {
	v, err := ioutil.ReadFile(filepath.Join(filepath.Dir(file), "version"))
	if err != nil {
		return internal.Version{}, err
	}

	return internal.Version{Ref: strings.TrimSpace(string(v))}, nil
}

func (Repository) version(semver *semver.Version) string {
	v := fmt.Sprintf("%d.%d.%d", semver.Major(), semver.Minor(), semver.Patch())
	if semver.Prerelease() != "" {
		v = fmt.Sprintf("%s_%s", v, semver.Prerelease())
	}
	return v
}
