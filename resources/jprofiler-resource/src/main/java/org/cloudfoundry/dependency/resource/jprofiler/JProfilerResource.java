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

package org.cloudfoundry.dependency.resource.jprofiler;

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
public class JProfilerResource {

    public static void main(String[] args) {
        SpringApplication.run(JProfilerResource.class, args);
    }

    @Bean
    @Profile("check")
    JProfilerCheckRequest checkRequest(ObjectMapper objectMapper) throws IOException {
        return objectMapper.readValue(System.in, JProfilerCheckRequest.class);
    }

    @Bean
    @Profile("in")
    JProfilerInRequest inRequest(ObjectMapper objectMapper) throws IOException {
        return objectMapper.readValue(System.in, JProfilerInRequest.class);
    }

}
