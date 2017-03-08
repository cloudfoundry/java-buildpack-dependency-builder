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
import org.cloudfoundry.dependency.OutputUtils;
import org.cloudfoundry.dependency.VersionReference;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.nio.file.Path;
import java.time.Duration;
import java.util.Collections;

@Component
@Profile("out")
final class OutAction implements CommandLineRunner {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    private final ObjectMapper objectMapper;

    private final OutRequest request;

    private final Path source;

    OutAction(ObjectMapper objectMapper, OutRequest request, Path source) {
        this.objectMapper = objectMapper;
        this.request = request;
        this.source = source;
    }

    @Override
    public void run(String... args) {
        run()
            .doOnNext(response -> this.logger.debug("Response: {}", response))
            .doOnNext(OutputUtils.write(this.objectMapper))
            .block(Duration.ofMinutes(5));
    }

    Mono<OutResponse> run() {
        return Mono.just(new OutResponse(Collections.emptyList(), new VersionReference("")));
    }

}
