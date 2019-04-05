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

package jprofiler

import (
	"fmt"
	"github.com/gocolly/colly"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
)

const root = "https://www.ej-technologies.com/download/jprofiler/files"

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile("Version: ([\\d]+)\\.([\\d]+)\\.?([\\d]+)?")}

type JProfiler struct {
	Version internal.Version `json:"version"`
}

func (j JProfiler) Check() (check.Result, error) {
	result := check.Result{Since: j.Version}

	c := colly.NewCollector()

	c.OnHTML(".version-meta h5", func(e *colly.HTMLElement) {

		_ = checkPattern.IfMatches(e.Text, func(g []string) error {
			ref := fmt.Sprintf("%s.%s", g[1], g[2])
			if g[3] != "" {
				ref = fmt.Sprintf("%s.%s", ref, g[3])
			}

			result.Add(internal.Version{Ref: ref})
			return nil
		})
	})

	err := c.Visit(root)
	return result, err
}

func (j JProfiler) In(destination string) (in.Result, error) {
	name, err := j.name()
	if err != nil {
		return in.Result{}, err
	}
	uri := j.uri(name)

	sha256, err := in.Artifact{
		Name:        name,
		Version:     j.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: j.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (j JProfiler) name() (string, error) {
	s, err := j.Version.AsSemver()
	if err != nil {
		return "", err
	}

	n := fmt.Sprintf("jprofiler_linux_%d_%d", s.Major(), s.Minor())

	if s.Patch() != 0 {
		n = fmt.Sprintf("%s_%d", n, s.Patch())
	}

	return fmt.Sprintf("%s.tar.gz", n), nil
}

func (j JProfiler) uri(name string) string {
	return fmt.Sprintf("https://download-keycdn.ej-technologies.com/jprofiler/%s", name)
}
