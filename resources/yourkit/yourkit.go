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

package yourkit

import (
	"fmt"
	"github.com/gocolly/colly"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
)

const root = "https://www.yourkit.com/download"

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile(".+/YourKit-JavaProfiler-([\\d]{4})\\.([\\d]{1,2})-b([\\d]+)\\.zip")}

type YourKit struct {
	Version internal.Version `json:"version"`
}

func (y YourKit) Check() (check.Result, error) {
	result := check.Result{Since: y.Version}

	c := colly.NewCollector()

	c.OnHTML("a[href]", func(e *colly.HTMLElement) {

		_ = checkPattern.IfMatches(e.Attr("href"), func(g []string) error {
			result.Add(internal.Version{Ref: fmt.Sprintf("%s.%s.%s", g[1], g[2], g[3])})
			return nil
		})
	})

	err := c.Visit(root)
	return result, err
}

func (y YourKit) In(destination string) (in.Result, error) {
	name, err := y.name()
	if err != nil {
		return in.Result{}, err
	}
	uri := y.uri(name)

	sha256, err := in.Artifact{
		Name:        name,
		Version:     y.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: y.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (y YourKit) name() (string, error) {
	s, err := y.Version.AsSemver()
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("YourKit-JavaProfiler-%d.%d-b%d.zip", s.Major(), s.Minor(), s.Patch()), nil
}

func (y YourKit) uri(name string) string {
	return fmt.Sprintf("%s/%s", root, name)
}
