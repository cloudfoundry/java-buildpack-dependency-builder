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

package skywalking

import (
	"fmt"
	"github.com/gocolly/colly"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
	"strings"
)

const root = "https://skywalking.apache.org/downloads"

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile("([\\d]+)\\.([\\d]+)\\.([\\d]+)")}

type SkyWalking struct {
	Version internal.Version `json:"version"`
}

func (s SkyWalking) Check() (check.Result, error) {
	result := check.Result{Since: s.Version}

	c := colly.NewCollector()

	c.OnHTML("table tbody tr td:nth-child(2)", func(e *colly.HTMLElement) {

		_ = checkPattern.IfMatches(e.Text, func(g []string) error {
			result.Add(internal.Version{Ref: fmt.Sprintf("%s.%s.%s", g[1], g[2], g[3])})
			return nil
		})
	})

	err := c.Visit(root)
	return result, err
}

func (s SkyWalking) In(destination string) (in.Result, error) {
	uri, err := s.uri()
	if err != nil {
		return in.Result{}, err
	}

	sha256, err := in.Artifact{
		Name:        s.name(),
		Version:     s.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: s.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (s SkyWalking) name() string {
	return fmt.Sprintf("apache-skywalking-apm-%s.tar.gz", s.Version.Ref)
}

func (s SkyWalking) uri() (string, error) {
	c := colly.NewCollector()

	var u string
	c.OnHTML("div.container p a strong", func(e *colly.HTMLElement) {
		u = strings.TrimSpace(e.Text)
	})

	if err := c.Visit(fmt.Sprintf("https://www.apache.org/dyn/closer.cgi/skywalking/%[1]s/apache-skywalking-apm-%[1]s.tar.gz", s.Version.Ref)); err != nil {
		return "", err
	}

	return u, nil
}
