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

package npm

import (
	"encoding/json"
	"fmt"
	"net/http"
	"resources/internal"
)

type metadata struct {
	Package string

	versions map[internal.Version]string
}

type version struct {
	Dist dist `json:"dist"`
}

type dist struct {
	URI string `json:"tarball"`
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
		Versions map[string]struct {
			Dist struct {
				Tarball string `json:"tarball"`
			} `json:"dist"`
		} `json:"versions"`
	}{}

	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return err
	}

	m.versions = make(map[internal.Version]string)
	for v, d := range raw.Versions {
		m.versions[internal.Version{Ref: v}] = d.Dist.Tarball
	}

	return nil
}

func (m *metadata) metadataUri() (string, error) {
	if m.Package == "" {
		return "", fmt.Errorf("package must be specified")
	}

	return fmt.Sprintf("https://registry.npmjs.org/%s", m.Package), nil
}
