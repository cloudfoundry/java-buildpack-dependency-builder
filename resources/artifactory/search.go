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

package artifactory

import (
	"encoding/json"
	"fmt"
	"net/http"
	"reflect"
	"regexp"
	"resources/internal"
)

var pattern = internal.Pattern{Regexp: regexp.MustCompile("^.+/([\\d]+)\\.([\\d]+)\\.([\\d]+)[.-]?(.*)/[^/]+$")}

type search struct {
	uri             string
	groupId         string
	artifactId      string
	repository      string
	artifactPattern internal.Pattern

	versions map[internal.Version]string
}

func (s *search) execute() error {
	uri, err := s.searchUri()
	if err != nil {
		return err
	}

	req, err := http.NewRequest("GET", uri, nil)
	if err != nil {
		return err
	}
	req.Header.Set("X-Result-Detail", "info")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("unable to download %s", uri)
	}

	b := struct {
		Results []struct {
			URI  string `json:"downloadUri"`
			Path string `json:"path"`
		} `json:"results"`
	}{}

	if err := json.NewDecoder(resp.Body).Decode(&b); err != nil {
		return err
	}

	s.versions = make(map[internal.Version]string)

	for _, r := range b.Results {
		if reflect.DeepEqual(s.artifactPattern, internal.Pattern{}) || s.artifactPattern.MatchString(r.Path) {
			if err := pattern.IfMatches(r.Path, func(g []string) error {
				ref := fmt.Sprintf("%s.%s.%s", g[1], g[2], g[3])
				if g[4] != "" {
					ref = fmt.Sprintf("%s-%s", ref, g[4])
				}

				s.versions[internal.Version{Ref: ref}] = r.URI
				return nil
			}); err != nil {
				return err
			}
		}
	}

	return nil
}

func (s search) searchUri() (string, error) {
	if s.uri == "" {
		return "", fmt.Errorf("uri must be specified")
	}

	if s.groupId == "" {
		return "", fmt.Errorf("group_id must be specified")
	}

	if s.artifactId == "" {
		return "", fmt.Errorf("artifact_id must be specified")
	}

	if s.repository == "" {
		return "", fmt.Errorf("repository must be specified")
	}

	return fmt.Sprintf("%s/api/search/gavc?g=%s&a=%s&repos=%s", s.uri, s.groupId, s.artifactId, s.repository), nil
}
