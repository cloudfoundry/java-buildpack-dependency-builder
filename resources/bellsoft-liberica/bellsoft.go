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

package bellsoft

import (
	"path/filepath"
	"resources/check"
	"resources/in"
	"resources/internal"
	"net/url"
)

type Bellsoft struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	Product string `json:"product"`
	Type           string `json:"type"`
	Version        string `json:"version"`
	Token		   string `json:"token"`
}

func (b Bellsoft) Check() (check.Result, error) {
	md := metadata{
		Product: b.Source.Product,
		Type:           b.Source.Type,
		Version:        b.Source.Version,
		Header:          b.Source.Token,
	}

	if err := md.load(); err != nil {
		return check.Result{}, err
	}
	

	result := check.Result{Since: b.Version}

	for v, _ := range md.versions {
		result.Add(v)
	}

	return result, nil
}

func (b Bellsoft) In(destination string) (in.Result, error) {
	md := metadata{
		Product:        b.Source.Product,
		Type:           b.Source.Type,
		Version:        b.Source.Version,
		Header:			b.Source.Token,
	}

	if err := md.load(); err != nil {
		return in.Result{}, err
	}
	
	uri := md.versions[b.Version]
	url, err := url.Parse(uri)
	if err != nil {
		return in.Result{}, err
	}

	sha256, err := in.Artifact{
		Name:        b.name(url.Path),
		Version:     b.Version,
		URI:         uri,
		Destination: destination,
		Header:      md.Header,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: b.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (Bellsoft) name(uri string) string {
	return filepath.Base(uri)
}
