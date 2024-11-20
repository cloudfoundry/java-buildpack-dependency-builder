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

package maven

import (
	"encoding/xml"
	"fmt"
	"net/http"
	"regexp"
	"resources/internal"
	"strings"
)

var pattern = internal.Pattern{Regexp: regexp.MustCompile("^([\\d]+)\\.([\\d]+)\\.([\\d]+)[.-]?(.*)")}

type metadata struct {
	uri        string
	groupId    string
	artifactId string
	user       string
	pass       string

	versions map[internal.Version]string
}

func (m *metadata) load() error {
	u, err := m.metadataUri()
	if err != nil {
		return err
	}

	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return err
	}
	if m.user != "" && m.pass != "" {
		req.SetBasicAuth(m.user, m.pass)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("unable to download %s, code %d", u, resp.StatusCode)
	}

	versions := struct {
		Versions []string `xml:"versioning>versions>version"`
	}{}

	if err := xml.NewDecoder(resp.Body).Decode(&versions); err != nil {
		return err
	}

	m.versions = make(map[internal.Version]string)
	for _, v := range versions.Versions {
		if err := pattern.IfMatches(v, func(g []string) error {
			ref := fmt.Sprintf("%s.%s.%s", g[1], g[2], g[3])
			if g[4] != "" {
				ref = fmt.Sprintf("%s-%s", ref, g[4])
			}

			m.versions[internal.Version{Ref: ref}] = v
			return nil
		}); err != nil {
			return err
		}
	}

	return nil
}

func (m *metadata) metadataUri() (string, error) {
	if m.uri == "" {
		return "", fmt.Errorf("uri must be specified")
	}
	if m.groupId == "" {
		return "", fmt.Errorf("group_id must be specified")
	}
	if m.artifactId == "" {
		return "", fmt.Errorf("artifact_id must be specified")
	}
	return fmt.Sprintf("%s/%s/%s/maven-metadata.xml", m.uri, strings.ReplaceAll(m.groupId, ".", "/"), m.artifactId), nil
}
