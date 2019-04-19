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

package npm

import (
	"path/filepath"
	"reflect"
	"resources/check"
	"resources/in"
	"resources/internal"
)

type NPM struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	Package        string           `json:"package"`
	VersionPattern internal.Pattern `json:"version_pattern"`
}

func (n NPM) Check() (check.Result, error) {
	md := metadata{
		Package: n.Source.Package,
	}

	if err := md.load(); err != nil {
		return check.Result{}, err
	}

	result := check.Result{Since: n.Version}

	for v, _ := range md.versions {
		if reflect.DeepEqual(n.Source.VersionPattern, internal.Pattern{}) || n.Source.VersionPattern.MatchString(v.Ref) {
			result.Add(v)
		}
	}

	return result, nil
}

func (n NPM) In(destination string) (in.Result, error) {
	md := metadata{
		Package: n.Source.Package,
	}

	if err := md.load(); err != nil {
		return in.Result{}, err
	}

	uri := md.versions[n.Version]

	sha256, err := in.Artifact{
		Name:        n.name(uri),
		Version:     n.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: n.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (NPM) name(uri string) string {
	return filepath.Base(uri)
}
