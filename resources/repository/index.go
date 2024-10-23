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
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"gopkg.in/yaml.v2"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"strings"
)

type index struct {
	session *session.Session
	bucket  string
	path    string
	uri     string

	contents map[string]string
}

func (i *index) Key() string {
	return path.Join(i.path, "index.yml")
}

func (i *index) load() error {
	if output, ok, err := i.loadS3(); err != nil {
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

func (i index) loadS3() (io.ReadCloser, bool, error) {
	if i.bucket == "" || i.path == "" {
		return nil, false, nil
	}

	s := s3.New(i.session)

	output, err := s.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(i.bucket),
		Key:    aws.String(i.Key()),
	})
	if err != nil {
		if a, ok := err.(awserr.Error); ok {
			switch a.Code() {
			case s3.ErrCodeNoSuchKey:
				return io.NopCloser(strings.NewReader("")), true, nil
			default:
				return nil, false, err
			}
		} else {
			return nil, false, err
		}

	}
	return output.Body, true, nil
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
	if i.bucket == "" {
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

	_, _ = fmt.Fprintf(os.Stderr, "Uploading s3://%s%s\n", i.bucket, i.Key())
	_, err := s3manager.NewUploader(i.session).Upload(&s3manager.UploadInput{
		Bucket:      aws.String(i.bucket),
		Key:         aws.String(i.Key()),
		Body:        in,
		ContentType: aws.String("text/x-yaml"),
	})

	return err
}
