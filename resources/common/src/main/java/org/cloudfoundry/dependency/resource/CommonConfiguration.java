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

package org.cloudfoundry.dependency.resource;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jdk8.Jdk8Module;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import reactor.ipc.netty.http.client.HttpClient;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
@ComponentScan
public class CommonConfiguration {

    @Bean
    HttpClient httpClient() {
        return HttpClient.create();
    }

    @Bean
    ObjectMapper objectMapper() {
        return new ObjectMapper()
            .addHandler(new LoggingDeserializationProblemHandler())
            .registerModule(new Jdk8Module());
    }

    @Bean
    OutputUtils outputUtils(ObjectMapper objectMapper) {
        return new OutputUtils(objectMapper);
    }

    @Configuration
    @Order(Ordered.LOWEST_PRECEDENCE)
    @Profile("check")
    class CheckConfiguration {

        @Bean
        @ConditionalOnMissingBean
        CheckAction checkAction(CheckRequest request, OutputUtils outputUtils) {
            return new CheckAction(request, outputUtils);
        }

        @Bean
        @ConditionalOnMissingBean
        CheckRequest checkRequest(ObjectMapper objectMapper) throws IOException {
            return objectMapper.readValue(System.in, CheckRequest.class);
        }

    }

    @Configuration
    @Order(Ordered.LOWEST_PRECEDENCE)
    @Profile("in")
    class InConfiguration {

        @Bean
        Path destination(ApplicationArguments applicationArguments) {
            return Paths.get(applicationArguments.getSourceArgs()[0]);
        }

        @Bean
        @ConditionalOnMissingBean
        InAction inAction(Path destination, InRequest request, OutputUtils outputUtils) {
            return new InAction(destination, request, outputUtils);
        }

        @Bean
        @ConditionalOnMissingBean
        InRequest inRequest(ObjectMapper objectMapper) throws IOException {
            return objectMapper.readValue(System.in, InRequest.class);
        }

    }

    @Configuration
    @Order(Ordered.LOWEST_PRECEDENCE)
    @Profile("out")
    class OutConfiguration {

        @Bean
        @ConditionalOnMissingBean
        OutAction outAction(OutputUtils outputUtils) {
            return new OutAction(outputUtils);
        }

        @Bean
        @ConditionalOnMissingBean
        OutRequest outRequest(ObjectMapper objectMapper) throws IOException {
            return objectMapper.readValue(System.in, OutRequest.class);
        }

        @Bean
        Path source(ApplicationArguments applicationArguments) {
            return Paths.get(applicationArguments.getSourceArgs()[0]);
        }

    }

}
