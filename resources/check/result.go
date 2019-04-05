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

package check

import (
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"resources/internal"
	"sort"
)

type Result struct {
	Since    internal.Version
	contents map[internal.Version]struct{}
}

func (r *Result) Add(v internal.Version) {
	if r.contents == nil {
		r.contents = make(map[internal.Version]struct{})
	}

	r.contents[v] = struct{}{}
}

func (r Result) MarshalJSON() ([]byte, error) {
	if r.contents == nil {
		return json.Marshal([]internal.Version{})
	}

	var versions []internal.Version

	for v, _ := range r.contents {
		versions = append(versions, v)
	}

	sort.Slice(versions, r.sort(versions))

	versions, err := r.filter(versions)
	if err != nil {
		return nil, err
	}

	return json.Marshal(versions)
}

func (r Result) filter(versions []internal.Version) ([]internal.Version, error) {
	if reflect.DeepEqual(r.Since, internal.Version{}) {
		return versions[len(versions)-1:], nil
	}

	s, err := r.Since.AsSemver()
	if err != nil {
		return nil, err
	}

	var l int
	for i, v := range versions {
		t, err := v.AsSemver()
		if err != nil {
			return nil, err
		}

		if t.Equal(s) || t.GreaterThan(s) {
			l = i
			break
		}
	}

	return versions[l:], nil
}

func (Result) sort(versions []internal.Version) func(i, j int) bool {
	return func(i, j int) bool {
		s, err := versions[i].AsSemver()
		if err != nil {
			_, _ = fmt.Fprintf(os.Stderr, "Unable to sort: %s", err)
			return true
		}

		t, err := versions[j].AsSemver()
		if err != nil {
			_, _ = fmt.Fprintf(os.Stderr, "Unable to sort: %s", err)
			return true
		}

		return s.LessThan(t)
	}
}
