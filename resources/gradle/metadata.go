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

package gradle

import (
	"encoding/json"
	"fmt"
	"net/http"
	"resources/internal"
)

type metadata struct {
	versions []internal.Version
}

func (m *metadata) load() error {
	u := "https://raw.githubusercontent.com/gradle/gradle/master/released-versions.json"

	resp, err := http.Get(u)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("unable to download %s", u)
	}

	versions := struct {
		FinalReleases []struct {
			Version string `json:"version"`
		} `json:"finalReleases"`
	}{}

	if err := json.NewDecoder(resp.Body).Decode(&versions); err != nil {
		return err
	}

	for _, r := range versions.FinalReleases {
		m.versions = append(m.versions, internal.Version{Ref: r.Version})
	}

	return nil
}
