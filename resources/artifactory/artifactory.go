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

package artifactory

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"resources/check"
	"resources/in"
	"resources/internal"
	"resources/out"
	"strings"

	"github.com/jfrog/jfrog-client-go/artifactory"
	"github.com/jfrog/jfrog-client-go/artifactory/auth"
	"github.com/jfrog/jfrog-client-go/artifactory/services"
	"github.com/jfrog/jfrog-client-go/config"
)

type Artifactory struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
	Parameters	parameters	 `json:"params"`
}

type source struct {
	ArtifactId      string           `json:"artifact_id"`
	ArtifactPattern internal.Pattern `json:"artifact_pattern"`
	GroupId         string           `json:"group_id"`
	Repository      string           `json:"repository"`
	URI             string           `json:"uri"`
}

type parameters struct {
	File                     string `json:"file"`
	ArtifactoryURL			 string `json:"artifactory_url"`
	APIKey					 string `json:"api_key"`
	User					 string `json:"user"`
	Password				 string `json:"password"`
	AccessToken				 string `json:"access_token"`
	Path					 string `json:"path"`
}

func (a Artifactory) Check() (check.Result, error) {
	s := search{
		uri:             a.Source.URI,
		groupId:         a.Source.GroupId,
		artifactId:      a.Source.ArtifactId,
		repository:      a.Source.Repository,
		artifactPattern: a.Source.ArtifactPattern,
	}

	if err := s.execute(); err != nil {
		return check.Result{}, err
	}

	result := check.Result{Since: a.Version}

	for v, _ := range s.versions {
		result.Add(v)
	}

	return result, nil
}

func (a Artifactory) In(destination string) (in.Result, error) {
	s := search{
		uri:             a.Source.URI,
		groupId:         a.Source.GroupId,
		artifactId:      a.Source.ArtifactId,
		repository:      a.Source.Repository,
		artifactPattern: a.Source.ArtifactPattern,
	}

	if err := s.execute(); err != nil {
		return in.Result{}, err
	}

	uri := s.versions[a.Version]

	sha256, err := in.Artifact{
		Name:        a.name(uri),
		Version:     a.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: a.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (a Artifactory) Out(source string) (out.Result, error) {
	rtDetails := auth.NewArtifactoryDetails()
	rtDetails.SetUrl(a.Parameters.ArtifactoryURL)
	rtDetails.SetApiKey(a.Parameters.APIKey)
	rtDetails.SetUser(a.Parameters.User)
	rtDetails.SetPassword(a.Parameters.Password)
	rtDetails.SetAccessToken(a.Parameters.AccessToken)
	serviceConfig, err := config.NewConfigBuilder().SetServiceDetails(rtDetails).Build()
	if err != nil {
		return out.Result{}, err
	}

	file, err := a.file(source)
	if err != nil {
		return out.Result{}, err
	}

	rtManager, err := artifactory.New(serviceConfig)
	params := services.NewUploadParams()
	params.Pattern = file
	params.Target = a.Parameters.Path
	params.Flat = true

	uploadServiceOptions := &artifactory.UploadServiceOptions{
    	// Set to true to fail the upload operation if any of the files fail to upload
    	FailFast: false,
	}

	_,_, err = rtManager.UploadFiles(*uploadServiceOptions, params)

	v, err := a.readVersion(file)
	if err != nil {
		return out.Result{}, err
	}
	sha256, err := a.readSHA256(file)
	if err != nil {
		return out.Result{}, err
	}

	return out.Result{
		Version: v,
		Metadata: []out.Metadata{
			{Name: "uri", Value: fmt.Sprintf("%s%s%s", a.Parameters.ArtifactoryURL, a.Parameters.Path, file)},
			{Name: "sha256", Value: sha256},
		},
	}, nil
}

func (Artifactory) readVersion(file string) (internal.Version, error) {
	v, err := os.ReadFile(filepath.Join(filepath.Dir(file), "version"))
	if err != nil {
		return internal.Version{}, err
	}

	return internal.Version{Ref: strings.TrimSpace(string(v))}, nil
}

func (Artifactory) readSHA256(file string) (string, error) {
	sha, err := os.ReadFile(filepath.Join(filepath.Dir(file), "sha256"))
	if err != nil {
		return "", err
	}

	return string(sha), nil
}

func (a Artifactory) file(source string) (string, error) {
	files, err := filepath.Glob(filepath.Join(source, a.Parameters.File))
	if err != nil {
		return "", err
	}

	if len(files) != 1 {
		return "", fmt.Errorf("%s did not match exactly one file: %s", a.Parameters.File, files)
	}

	return files[0], nil
}

func (a Artifactory) name(uri string) string {
	return path.Base(uri)
}
