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
	"net/url"
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
		Binaries []struct {
			Package struct {
				Link string `json:"link"`
			} `json:"package"`
		} `json:"binaries"`
		VersionData struct {
			SemVer string `json:"semver"`
		} `json:"version_data"`
	}, 1)

	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return err
	}

	m.versions = make(map[internal.Version]string)
	for _, r := range raw {
		m.versions[internal.Version{Ref: r.VersionData.SemVer}] = r.Binaries[0].Package.Link
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

	return fmt.Sprintf("https://api.adoptopenjdk.net/v3/assets/version/%s?architecture=x64&heap_size=normal&image_type=%s&jvm_impl=%s&os=linux&release_type=ga&vendor=adoptopenjdk",
		url.PathEscape(m.Version), m.Type, m.Implementation), nil
}
