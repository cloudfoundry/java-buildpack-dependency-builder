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

package internal

import (
	"encoding/json"
	"regexp"
)

type Pattern struct {
	*regexp.Regexp
}

type CallBack func(g []string) error

func (p Pattern) IfMatches(s string, callback CallBack) error {
	if g := p.FindStringSubmatch(s); g != nil {
		return callback(g)
	}
	return nil
}

func (p *Pattern) UnmarshalJSON(text []byte) error {
	var pattern string
	if err := json.Unmarshal(text, &pattern); err != nil {
		return err
	}

	q, err := regexp.Compile(pattern)
	if err != nil {
		return err
	}

	p.Regexp = q
	return nil
}
