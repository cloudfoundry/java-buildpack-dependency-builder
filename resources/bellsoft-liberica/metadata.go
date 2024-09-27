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
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"resources/internal"
	"strings"
)

type metadata struct {
	Version        string
	Product        string
	Type           string
	Header         string

	versions map[internal.Version]string
}

func (m *metadata) load() error {
	u, err := m.metadataUri()
	if err != nil {
		return err
	}

	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		return fmt.Errorf("unable to create GET %s request\n%w", u, err)
	}
	if m.Header != "" {
		subs := strings.SplitAfterN(m.Header, " ", 2)
		name := strings.ReplaceAll(subs[0], ":", "")
		value := subs[1]
		req.Header.Add(strings.TrimSpace(name), value)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil || resp.StatusCode != 200 {
		return fmt.Errorf("unable to get %s\n%w", u, err)
	}
	defer resp.Body.Close()
	
	var raw []Release
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		panic(fmt.Errorf("unable to decode payload\n%w", err))
	}

	m.versions = make(map[internal.Version]string)
	for _, r := range raw {
		key := fmt.Sprintf("%d.%d.%d+%d", r.FeatureVersion, r.InterimVersion, r.UpdateVersion, r.BuildVersion)
		m.versions[internal.Version{Ref: key}] = r.DownloadURL
	}

	return nil
}

func (m *metadata) metadataUri() (string, error) {
	if m.Version == "" {
		return "", fmt.Errorf("version must be specified")
	}

	if m.Product == "" {
		return "", fmt.Errorf("product must be specified")
	}

	if m.Type == "" {
		return "", fmt.Errorf("type must be specified")
	}

	commonStaticParams := "&version-modifier=latest"
	uriStaticParams := "?arch=x86" +
		"&bitness=64" +
		"&os=linux" +
		"&package-type=tar.gz" +
		commonStaticParams

	return fmt.Sprintf("https://api.bell-sw.com/v1/liberica/releases"+
			uriStaticParams+
			"&bundle-type=%s"+
			"&version-feature=%s",
	        m.Type, url.PathEscape(m.Version)), nil
}


type Release struct {
	FeatureVersion int    `json:"featureVersion"`
	InterimVersion int    `json:"interimVersion"`
	UpdateVersion  int    `json:"updateVersion"`
	BuildVersion   int    `json:"buildVersion"`
	DownloadURL    string `json:"downloadUrl"`
	Components     []struct {
		Version   string `json:"version"`
		Component string `json:"component"`
	}
}
