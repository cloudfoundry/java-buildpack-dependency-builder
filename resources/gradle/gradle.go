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

package gradle

import (
	"fmt"
	"reflect"
	"resources/check"
	"resources/in"
	"resources/internal"
)

type Gradle struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	VersionPattern internal.Pattern `json:"version_pattern"`
}

func (g Gradle) Check() (check.Result, error) {
	md := metadata{}

	if err := md.load(); err != nil {
		return check.Result{}, err
	}

	result := check.Result{Since: g.Version}

	for _, v := range md.versions {
		if reflect.DeepEqual(g.Source.VersionPattern, internal.Pattern{}) || g.Source.VersionPattern.MatchString(v.Ref) {
			result.Add(v)
		}
	}

	return result, nil
}

func (g Gradle) In(destination string) (in.Result, error) {
	name := g.name()
	uri := g.uri(name)

	sha256, err := in.Artifact{
		Name:        name,
		Version:     g.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: g.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (g Gradle) name() string {
	return fmt.Sprintf("gradle-%s-bin.zip", g.Version.Ref)
}

func (Gradle) uri(name string) string {
	return fmt.Sprintf("https://downloads.gradle.org/distributions/%s", name)
}
