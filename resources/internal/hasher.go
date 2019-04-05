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
	"fmt"
	"hash"
	"io"
)

type Hasher struct {
	Hash   hash.Hash
	Reader io.ReadCloser
	Writer io.WriteCloser
}

func (h Hasher) AsHex() string {
	return fmt.Sprintf("%x", h.Hash.Sum(nil))
}

func (h Hasher) Close() error {
	if h.Reader != nil {
		if err := h.Reader.Close(); err != nil {
			return err
		}
	}

	if h.Writer != nil {
		if err := h.Writer.Close(); err != nil {
			return err
		}
	}

	return nil
}

func (h Hasher) Read(p []byte) (int, error) {
	n, err := h.Reader.Read(p)
	if err != nil {
		return 0, err
	}

	_, err = h.Hash.Write(p[:n])
	if err != nil {
		return 0, err
	}

	return n, nil
}

func (h Hasher) Write(p []byte) (int, error) {
	n, err := h.Writer.Write(p)
	if err != nil {
		return 0, err
	}

	_, err = h.Hash.Write(p)
	if err != nil {
		return 0, err
	}

	return n, nil
}
