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
	"crypto/sha256"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"resources/internal"

	"cloud.google.com/go/storage"
)

type artifact struct {
	client *storage.Client

	file   string
	bucketHandle string
	path   string
}

func (a artifact) Key() string {
	return filepath.Join(a.path, filepath.Base(a.file))
}

func (a artifact) Upload() (string, error) {

	ctx := context.Background()
	bucket := a.client.Bucket(a.bucketHandle)

	key := a.Key()
	_, _ = fmt.Fprintf(os.Stderr, "Uploading gcs://%s/%s\n", a.bucketHandle, key)

	obj := bucket.Object(key)
	// Write something to obj.
	// w implements io.Writer.
	w := obj.NewWriter(ctx)
	
	in, err := os.Open(a.file)
	if err != nil {
		return "", fmt.Errorf("error opening file: %w", err)
	}
	defer in.Close()

	if _, err = io.Copy(w, in); err != nil {
		return "", fmt.Errorf("error copying file: %w", err)
	}

	// Close, just like writing a file.
	if err := w.Close(); err != nil {
		return "", fmt.Errorf("error closing file: %w", err)
	}

	h := internal.Hasher{
		Hash:   sha256.New(),
		Reader: in,
	}

	return h.AsHex(), nil
}
