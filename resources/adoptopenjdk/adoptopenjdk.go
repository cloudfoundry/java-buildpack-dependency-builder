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

package adoptopenjdk

import (
	"path/filepath"
	"resources/check"
	"resources/in"
	"resources/internal"
)

type AdoptOpenJDK struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	Implementation string `json:"implementation"`
	Type           string `json:"type"`
	Version        string `json:"version"`
}

func (a AdoptOpenJDK) Check() (check.Result, error) {
	md := metadata{
		Implementation: a.Source.Implementation,
		Type:           a.Source.Type,
		Version:        a.Source.Version,
	}

	if err := md.load(); err != nil {
		return check.Result{}, err
	}

	result := check.Result{Since: a.Version}

	for v, _ := range md.versions {
		result.Add(v)
	}

	return result, nil
}

func (a AdoptOpenJDK) In(destination string) (in.Result, error) {
	md := metadata{
		Implementation: a.Source.Implementation,
		Type:           a.Source.Type,
		Version:        a.Source.Version,
	}

	if err := md.load(); err != nil {
		return in.Result{}, err
	}

	uri := md.versions[a.Version]

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

func (AdoptOpenJDK) name(uri string) string {
	return filepath.Base(uri)
}
