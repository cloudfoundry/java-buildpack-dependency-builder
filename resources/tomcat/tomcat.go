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

package tomcat

import (
	"fmt"
	"github.com/gocolly/colly"
	"reflect"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
)

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile("^v([\\d]+)\\.([\\d]+)\\.([\\d]+)/$")}

type Tomcat struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	URI            string           `json:"uri"`
	VersionPattern internal.Pattern `json:"version_pattern"`
}

func (t Tomcat) Check() (check.Result, error) {
	if t.Source.URI == "" {
		return check.Result{}, fmt.Errorf("uri must be specified")
	}

	result := check.Result{Since: t.Version}

	c := colly.NewCollector()

	c.OnHTML("a[href]", func(e *colly.HTMLElement) {
		_ = checkPattern.IfMatches(e.Attr("href"), func(g []string) error {

			ref := fmt.Sprintf("%s.%s.%s", g[1], g[2], g[3])

			if reflect.DeepEqual(t.Source.VersionPattern, internal.Pattern{}) || t.Source.VersionPattern.MatchString(ref) {
				result.Add(internal.Version{Ref: ref})
			}

			return nil
		})

	})

	err := c.Visit(t.Source.URI)
	return result, err
}

func (t Tomcat) In(destination string) (in.Result, error) {
	uri := t.uri()

	sha256, err := in.Artifact{
		Name:        t.name(),
		Version:     t.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: t.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (t Tomcat) name() string {
	return fmt.Sprintf("apache-tomcat-%s.tar.gz", t.Version.Ref)
}

func (t Tomcat) uri() string {
	return fmt.Sprintf("%s/v%s/bin/%s", t.Source.URI, t.Version.Ref, t.name())
}
