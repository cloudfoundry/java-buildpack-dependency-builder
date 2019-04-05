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
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudfront"
	"os"
	"time"
)

type distribution struct {
	session        *session.Session
	distributionId string
	paths          []string
}

func (d distribution) invalidate() error {
	c := cloudfront.New(d.session)

	var p []*string
	for _, path := range d.paths {
		p = append(p, aws.String(path))
	}

	q := int64(len(d.paths))

	ci, err := c.CreateInvalidation(&cloudfront.CreateInvalidationInput{
		DistributionId: aws.String(d.distributionId),
		InvalidationBatch: &cloudfront.InvalidationBatch{
			CallerReference: aws.String(time.Now().String()),
			Paths: &cloudfront.Paths{
				Items:    p,
				Quantity: &q,
			},
		},
	})
	if err != nil {
		return err
	}

	i := ci.Invalidation.Id

	_, _ = fmt.Fprintf(os.Stderr, "Waiting for invalidation %s", *i)

	for {
		gi, err := c.GetInvalidation(&cloudfront.GetInvalidationInput{
			DistributionId: aws.String(d.distributionId),
			Id:             i,
		})
		if err != nil {
			return err
		}

		if *gi.Invalidation.Status != "InProgress" {
			break
		}

		_, _ = fmt.Fprintf(os.Stderr, ".")
		time.Sleep(10 * time.Second)
	}

	_, _ = fmt.Fprintln(os.Stderr)
	return nil
}
