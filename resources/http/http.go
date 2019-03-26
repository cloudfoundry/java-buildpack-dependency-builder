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

package http

import (
	"fmt"
	"net/http"
	"path"
	"resources/check"
	"resources/in"
	"resources/internal"
)

type Http struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	URI string `json:"uri"`
}

func (h Http) Check() (check.Result, error) {
	if h.Source.URI == "" {
		return check.Result{}, fmt.Errorf("uri must be specified")
	}

	resp, err := http.Head(h.Source.URI)
	if err != nil {
		return check.Result{}, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return check.Result{}, fmt.Errorf("unable to download %s", h.Source.URI)
	}

	result := check.Result{Since: h.Version}

	t, err := http.ParseTime(resp.Header.Get("Last-Modified"))
	if err != nil {
		return check.Result{}, err
	}

	result.Add(internal.Version{Ref: t.Format("2006.01.02-150405")})

	return result, nil
}

func (h Http) In(destination string) (in.Result, error) {
	sha256, err := in.Artifact{
		Name:        h.name(),
		Version:     h.Version,
		URI:         h.Source.URI,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: h.Version,
		Metadata: []in.Metadata{
			{"uri", h.Source.URI},
			{"sha256", sha256},
		},
	}, nil
}

func (h Http) name() string {
	return path.Base(h.Source.URI)
}
