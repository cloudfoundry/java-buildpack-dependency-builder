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

package adoptopenjdk

import (
	"encoding/json"
	"fmt"
	"net/http"
	"resources/internal"
)

type metadata struct {
	Version        string
	Implementation string
	Type           string

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
	raw := make([]struct {
		BinaryLink  string `json:"binary_link"`
		VersionData struct {
			SemVer string `json:"semver"`
		} `json:"version_data"`
	}, 1)

	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return err
	}

	m.versions = make(map[internal.Version]string)
	for _, r := range raw {
		m.versions[internal.Version{Ref: r.VersionData.SemVer}] = r.BinaryLink
	}

	return nil
}

func (m *metadata) metadataUri() (string, error) {
	if m.Version == "" {
		return "", fmt.Errorf("version must be specified")
	}

	if m.Implementation == "" {
		return "", fmt.Errorf("implementation must be specified")
	}

	if m.Type == "" {
		return "", fmt.Errorf("type must be specified")
	}

	return fmt.Sprintf("https://api.adoptopenjdk.net/v2/latestAssets/releases/%s?heap_size=normal&os=linux&arch=x64&openjdk_impl=%s&type=%s",
		m.Version, m.Implementation, m.Type), nil
}
