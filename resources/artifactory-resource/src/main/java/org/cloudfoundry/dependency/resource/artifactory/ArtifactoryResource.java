/*
 * Copyright 2017-2018 the original author or authors.
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

package org.cloudfoundry.dependency.resource.artifactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.resource.CommonConfiguration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Profile;

import java.io.IOException;

@Import(CommonConfiguration.class)
@SpringBootApplication
public class ArtifactoryResource {

    public static void main(String[] args) {
        SpringApplication.run(ArtifactoryResource.class, args);
    }

    @Bean
    @Profile("check")
    ArtifactoryCheckRequest checkRequest(ObjectMapper objectMapper) throws IOException {
        return objectMapper.readValue(System.in, ArtifactoryCheckRequest.class);
    }

    @Bean
    @Profile("in")
    ArtifactoryInRequest inRequest(ObjectMapper objectMapper) throws IOException {
        return objectMapper.readValue(System.in, ArtifactoryInRequest.class);
    }

}
