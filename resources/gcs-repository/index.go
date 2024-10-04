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

package gcsrepository

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"

	"cloud.google.com/go/storage"
	"gopkg.in/yaml.v2"
)

type index struct {
	client *storage.Client
	bucketHandle  string
	path    string
	uri     string

	contents map[string]string
}

func (i *index) Key() string {
	return path.Join(i.path, "index.yml")
}

func (i *index) load() error {
	if output, ok, err := i.loadGCS(); err != nil {
		return err
	} else if ok {
		defer output.Close()

		switch yaml.NewDecoder(output).Decode(&i.contents) {
		case io.EOF:
			i.contents = make(map[string]string)
			return nil
		default:
			return err
		}
	}

	if output, ok, err := i.loadURI(); err != nil {
		return err
	} else if ok {
		defer output.Close()

		switch yaml.NewDecoder(output).Decode(&i.contents) {
		case io.EOF:
			i.contents = make(map[string]string)
			return nil
		default:
			return err
		}
	}

	return fmt.Errorf("either bucket and path or uri must be specified")
}

func (i index) loadGCS() (io.ReadCloser, bool, error) {
	if i.bucketHandle == "" || i.path == "" {
		return nil, false, nil
	}

	ctx := context.Background()

	rc, err := i.client.Bucket(i.bucketHandle).Object(i.Key()).NewReader(ctx)
	if err != nil {
		return nil, false, fmt.Errorf("error reading object: %s\n%w", i.Key(), err)
	}
	defer rc.Close()

	return rc, true, nil
}

func (i index) loadURI() (io.ReadCloser, bool, error) {
	if i.uri == "" {
		return nil, false, nil
	}

	u, err := url.Parse(i.uri)
	if err != nil {
		return nil, false, err
	}
	u.Path = path.Join(u.Path, "index.yml")

	r, err := http.Get(u.String())
	if err != nil {
		return nil, false, err
	}

	return r.Body, true, nil
}

func (i index) save() error {
	if i.bucketHandle == "" {
		return fmt.Errorf("bucket must be specified")
	}

	if i.path == "" {
		return fmt.Errorf("path must be specified")
	}

	in, out := io.Pipe()

	go func() {
		if err := yaml.NewEncoder(out).Encode(i.contents); err != nil {
			log.Fatal("Unable to encode index")
		}
		defer out.Close()
	}()

	ctx := context.Background()
	bucket := i.client.Bucket(i.bucketHandle)

	key := i.Key()
	_, _ = fmt.Fprintf(os.Stderr, "Uploading gcs://%s/%s\n", i.bucketHandle, key)

	obj := bucket.Object(key)
	// Write something to obj.
	// w implements io.Writer.
	w := obj.NewWriter(ctx)

	if _, err := io.Copy(w, in); err != nil {
		return fmt.Errorf("error copying file: %w", err)
	}

	// Close, just like writing a file.
	if err := w.Close(); err != nil {
		return fmt.Errorf("error closing file: %w", err)
	}

	return nil
}
