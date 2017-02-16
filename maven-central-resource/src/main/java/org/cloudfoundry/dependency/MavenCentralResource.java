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

package org.cloudfoundry.dependency;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.deser.DeserializationProblemHandler;
import com.fasterxml.jackson.datatype.jdk8.Jdk8Module;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import reactor.ipc.netty.http.client.HttpClient;

import java.io.IOException;

@SpringBootApplication
public class MavenCentralResource {

    public static void main(String[] args) throws IOException, InterruptedException {
        SpringApplication.run(MavenCentralResource.class, args);
    }

    @Bean
    @Profile({"check", "in"})
    HttpClient httpClient() {
        return HttpClient.create();
    }

    @Bean
    ObjectMapper objectMapper() {
        return new ObjectMapper()
            .addHandler(new LoggingDeserializationProblemHandler())
            .registerModule(new Jdk8Module());
    }

    private static final class LoggingDeserializationProblemHandler extends DeserializationProblemHandler {

        private final Logger logger = LoggerFactory.getLogger(LoggingDeserializationProblemHandler.class);

        @Override
        public boolean handleUnknownProperty(DeserializationContext ctxt, JsonParser p, JsonDeserializer<?> deserializer, Object beanOrClass, String propertyName) throws IOException {
            this.logger.warn("{} is an unnecessary configuration parameter", propertyName);
            p.skipChildren();
            return true;
        }

    }

}
