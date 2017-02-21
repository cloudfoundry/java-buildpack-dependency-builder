/*
 * Copyright 2017 the original author or authors.
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

package org.cloudfoundry.dependency.out;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
@Profile("out")
class OutConfiguration {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Bean
    Path source(ApplicationArguments applicationArguments) {
        Path source = Paths.get(applicationArguments.getSourceArgs()[0]);
        this.logger.debug("Source: {}", source);
        return source;
    }

    @Bean
    OutRequest outRequest(ObjectMapper objectMapper) throws IOException {
        OutRequest request = objectMapper.readValue(System.in, OutRequest.class);
        this.logger.debug("Request: {}", request);
        return request;
    }

}
