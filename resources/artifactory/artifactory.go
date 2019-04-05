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
	"path"
	"resources/check"
	"resources/in"
	"resources/internal"
)

type Artifactory struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	ArtifactId      string           `json:"artifact_id"`
	ArtifactPattern internal.Pattern `json:"artifact_pattern"`
	GroupId         string           `json:"group_id"`
	Repository      string           `json:"repository"`
	URI             string           `json:"uri"`
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

func (a Artifactory) name(uri string) string {
	return path.Base(uri)
}
