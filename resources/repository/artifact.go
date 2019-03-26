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

package repository

import (
	"crypto/sha256"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"os"
	"path/filepath"
	"resources/internal"
)

type artifact struct {
	session *session.Session

	file   string
	bucket string
	path   string
}

func (a artifact) Key() string {
	return filepath.Join(a.path, filepath.Base(a.file))
}

func (a artifact) Upload() (string, error) {
	key := a.Key()
	_, _ = fmt.Fprintf(os.Stderr, "Uploading s3://%s%s\n", a.bucket, key)

	in, err := os.Open(a.file)
	if err != nil {
		return "", err
	}
	defer in.Close()

	h := internal.Hasher{
		Hash:   sha256.New(),
		Reader: in,
	}

	if _, err := s3manager.NewUploader(a.session).Upload(&s3manager.UploadInput{
		Bucket: aws.String(a.bucket),
		Key:    aws.String(key),
		Body:   h,
	}); err != nil {
		return "", err
	}

	return h.AsHex(), nil
}
