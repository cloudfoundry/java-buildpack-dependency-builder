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

package zulu

import (
	"encoding/json"
	"fmt"
	"net/http"
	"resources/internal"
)

type metadata struct {
	Type    string
	Version string

	versions map[internal.Version]string
}

func (m *metadata) load() error {
	u, err := m.metadataUri()
	if err != nil {
		return err
	}

	resp, err := http.Get(u)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("unable to download %s", u)
	}

	raw := struct {
		JDKVersion []int  `json:"jdk_version"`
		URL        string `json:"url"`
	}{}

	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return err
	}

	version, err := m.version(raw.JDKVersion)
	if err != nil {
		return err
	}

	m.versions = map[internal.Version]string{internal.Version{Ref: version}: raw.URL}

	return nil
}

func (m *metadata) metadataUri() (string, error) {
	if m.Version == "" {
		return "", fmt.Errorf("version must be specified")
	}

	if m.Type == "" {
		return "", fmt.Errorf("type must be specified")
	}

	return fmt.Sprintf("https://api.azul.com/zulu/download/azure-only/v1.0/bundles/latest/?arch=x86&bundle_type=%s&ext=tar.gz&hw_bitness=64&jdk_version=%s&os=linux",
		m.Type, m.Version), nil
}

func (m *metadata) version(raw []int) (string, error) {
	if len(raw) != 3 {
		return "", fmt.Errorf("version must have three components: %d", len(raw))
	}

	return fmt.Sprintf("%d.%d.%d", raw[0], raw[1], raw[2]), nil
}
