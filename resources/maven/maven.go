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

package maven

import (
	"fmt"
	"reflect"
	"resources/check"
	"resources/in"
	"resources/internal"
	"strings"
)

type Maven struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	ArtifactId     string           `json:"artifact_id"`
	Classifier     string           `json:"classifier"`
	GroupId        string           `json:"group_id"`
	Packaging      string           `json:"packaging"`
	URI            string           `json:"uri"`
	VersionPattern internal.Pattern `json:"version_pattern"`
}

func (m Maven) Check() (check.Result, error) {
	md := metadata{
		uri:        m.Source.URI,
		groupId:    m.Source.GroupId,
		artifactId: m.Source.ArtifactId,
	}

	if err := md.load(); err != nil {
		return check.Result{}, err
	}

	result := check.Result{Since: m.Version}

	for v, _ := range md.versions {
		if reflect.DeepEqual(m.Source.VersionPattern, internal.Pattern{}) || m.Source.VersionPattern.MatchString(v.Ref) {
			result.Add(v)
		}
	}

	return result, nil
}

func (m Maven) In(destination string) (in.Result, error) {
	version, err := m.version()
	if err != nil {
		return in.Result{}, err
	}

	name, err := m.name(version)
	if err != nil {
		return in.Result{}, err
	}

	uri, err := m.uri(version, name)
	if err != nil {
		return in.Result{}, err
	}

	sha256, err := in.Artifact{
		Name:        name,
		Version:     m.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: m.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (m Maven) name(version string) (string, error) {
	s := m.Source

	if s.ArtifactId == "" {
		return "", fmt.Errorf("artifact_id must be specified")
	}

	n := fmt.Sprintf("%s-%s", s.ArtifactId, version)

	if s.Classifier != "" {
		n = fmt.Sprintf("%s-%s", n, s.Classifier)
	}

	var p string
	if s.Packaging == "" {
		p = "jar"
	} else {
		p = s.Packaging
	}

	return fmt.Sprintf("%s.%s", n, p), nil
}

func (m Maven) uri(version string, name string) (string, error) {
	s := m.Source

	if s.URI == "" {
		return "", fmt.Errorf("uri must be specified")
	}
	if s.GroupId == "" {
		return "", fmt.Errorf("group_id must be specified")
	}
	if s.ArtifactId == "" {
		return "", fmt.Errorf("artifact_id must be specified")
	}

	return fmt.Sprintf("%s/%s/%s/%s/%s",
		s.URI, strings.ReplaceAll(s.GroupId, ".", "/"), s.ArtifactId, version, name), nil
}

func (m Maven) version() (string, error) {
	md := metadata{
		uri:        m.Source.URI,
		groupId:    m.Source.GroupId,
		artifactId: m.Source.ArtifactId,
	}

	if err := md.load(); err != nil {
		return "", err
	}

	return md.versions[m.Version], nil
}
