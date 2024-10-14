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
	"net/http"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"

	"github.com/PuerkitoBio/goquery"
)

const root = "https://www.ej-technologies.com/download/jprofiler/files"

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile(`^Release ([\d]+)\.([\d]+)\.([\d]+).*$`)}

type JProfiler struct {
	Version internal.Version `json:"version"`
}

func (j JProfiler) Check() (check.Result, error) {
	result := check.Result{Since: j.Version}

	res, err := http.Get("https://www.ej-technologies.com/jprofiler/changelog")
	if err != nil {
		return check.Result{}, fmt.Errorf("error retrieving changelog\n%w", err)
	}
	defer res.Body.Close()

	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		return check.Result{}, fmt.Errorf("error parsing response\n%w", err)
	}

	doc.Find("div.release-heading").Each(func(i int, s *goquery.Selection) {
		if p := checkPattern.FindStringSubmatch(s.Text()); p != nil { 
			ref := fmt.Sprintf("%s.%s.%s", p[1], p[2], p[3])
			result.Add(internal.Version{Ref: ref})
		}
	})

	return result, nil
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
	return fmt.Sprintf("https://download-gcdn.ej-technologies.com/jprofiler/%s", name)
}
