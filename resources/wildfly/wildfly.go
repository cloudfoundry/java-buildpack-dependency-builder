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

package wildfly

import (
	"fmt"
	"github.com/gocolly/colly"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
)

const root = "https://wildfly.org/downloads"

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile("([\\d]+)\\.([\\d]+)\\.([\\d]+)\\.Final")}

type WildFly struct {
	Version internal.Version `json:"version"`
}

func (w WildFly) Check() (check.Result, error) {
	result := check.Result{Since: w.Version}

	c := colly.NewCollector()

	c.OnHTML("table tbody tr td:first-child", func(e *colly.HTMLElement) {

		_ = checkPattern.IfMatches(e.Text, func(g []string) error {
			result.Add(internal.Version{Ref: fmt.Sprintf("%s.%s.%s-Final", g[1], g[2], g[3])})
			return nil
		})
	})

	err := c.Visit(root)
	return result, err
}

func (w WildFly) In(destination string) (in.Result, error) {
	name, err := w.name()
	if err != nil {
		return in.Result{}, err
	}
	uri, err := w.uri(name)
	if err != nil {
		return in.Result{}, err
	}

	sha256, err := in.Artifact{
		Name:        name,
		Version:     w.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: w.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (w WildFly) name() (string, error) {
	v, err := w.version()
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("wildfly-%s.tar.gz", v), nil
}

func (w WildFly) uri(name string) (string, error) {
	v, err := w.version()
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("https://download.jboss.org/wildfly/%s/%s", v, name), err
}

func (w WildFly) version() (string, error) {
	s, err := w.Version.AsSemver()
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%d.%d.%d.%s", s.Major(), s.Minor(), s.Patch(), s.Prerelease()), nil
}
