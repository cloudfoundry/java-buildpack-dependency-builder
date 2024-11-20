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

package in

import (
	"crypto/sha256"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"resources/internal"
)

type Artifact struct {
	Name        string
	Version     internal.Version
	URI         string
	Destination string
	Header      string
}

type RequestModifierFunc func(request *http.Request) *http.Request

func (a Artifact) Download(mods ...RequestModifierFunc) (string, error) {
	out, err := os.Create(filepath.Join(a.Destination, a.Name))
	if err != nil {
		return "", fmt.Errorf("unable to create file \n%w", err)
	}
	defer out.Close()

	req, err := http.NewRequest("GET", a.URI, nil)
	if err != nil {
		return "", fmt.Errorf("unable to create GET %s request\n%w", a.URI, err)
	}

	for _, m := range mods {
		req = m(req)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("unable to get %s\n%w", a.URI, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("unable to download %s, code %d", a.URI, resp.StatusCode)
	}

	_, _ = fmt.Fprintf(os.Stderr, "Downloading %s\n", a.URI)

	h := internal.Hasher{
		Hash:   sha256.New(),
		Writer: out,
	}

	if _, err := io.Copy(h, resp.Body); err != nil {
		return "", err
	}

	hash := h.AsHex()
	if err := os.WriteFile(filepath.Join(a.Destination, "sha256"), []byte(hash), 0644); err != nil {
		return "", err
	}

	if err := os.WriteFile(filepath.Join(a.Destination, "uri"), []byte(a.URI), 0644); err != nil {
		return "", err
	}

	if err := os.WriteFile(filepath.Join(a.Destination, "version"), []byte(a.Version.Ref), 0644); err != nil {
		return "", err
	}

	return hash, nil
}
