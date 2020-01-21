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

package corretto

import (
	"context"
	"fmt"
	"github.com/google/go-github/github"
	"regexp"
	"resources/check"
	"resources/in"
	"resources/internal"
	"strings"
)

var checkPattern = internal.Pattern{Regexp: regexp.MustCompile("([\\d]+)\\.([\\d]+)\\.([\\d]+)\\.(.+)")}

type Corretto struct {
	Source  source           `json:"source"`
	Version internal.Version `json:"version"`
}

type source struct {
	Owner      string `json:"owner"`
	Password   string `json:"password"`
	Repository string `json:"repository"`
	Username   string `json:"username"`
}

func (c Corretto) Check() (check.Result, error) {
	result := check.Result{Since: c.Version}

	client, err := c.client()
	if err != nil {
		return check.Result{}, err
	}

	r, err := c.releases(client)
	if err != nil {
		return check.Result{}, err
	}

	for _, v := range r {
		_ = checkPattern.IfMatches(v.GetTagName(), func(g []string) error {
			result.Add(internal.Version{Ref: fmt.Sprintf("%s.%s.%s-%s", g[1], g[2], g[3], g[4])})
			return nil
		})
	}

	return result, nil
}

func (c Corretto) In(destination string) (in.Result, error) {
	name := c.name()
	uri := c.uri(name)

	sha256, err := in.Artifact{
		Name:        name,
		Version:     c.Version,
		URI:         uri,
		Destination: destination,
	}.Download()
	if err != nil {
		return in.Result{}, err
	}

	return in.Result{
		Version: c.Version,
		Metadata: []in.Metadata{
			{"uri", uri},
			{"sha256", sha256},
		},
	}, nil
}

func (c Corretto) client() (*github.Client, error) {
	if c.Source.Username == "" {
		return nil, fmt.Errorf("username must be set")
	}

	if c.Source.Password == "" {
		return nil, fmt.Errorf("password must be set")
	}

	t := github.BasicAuthTransport{Username: c.Source.Username, Password: c.Source.Password}
	return github.NewClient(t.Client()), nil
}

func (c Corretto) name() string {
	s := strings.Replace(c.Version.Ref, "-", ".", -1)
	return fmt.Sprintf("amazon-corretto-%s-linux-x64.tar.gz", s)
}

func (c Corretto) releases(client *github.Client) ([]*github.RepositoryRelease, error) {
	var releases []*github.RepositoryRelease

	opt := &github.ListOptions{PerPage: 100}

	for {
		s, r, err := client.Repositories.ListReleases(context.Background(), c.Source.Owner, c.Source.Repository, opt)
		if err != nil {
			return nil, fmt.Errorf("unable to list existing webhooks %s: %s", c.Source.Repository, err)
		}

		releases = append(releases, s...)

		if r.NextPage == 0 {
			break
		}

		opt.Page = r.NextPage
	}

	return releases, nil
}

func (c Corretto) uri(name string) string {
	s := strings.Replace(c.Version.Ref, "-", ".", -1)
	return fmt.Sprintf("https://corretto.aws/downloads/resources/%s/%s", s, name)
}
