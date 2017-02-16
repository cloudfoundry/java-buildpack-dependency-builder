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

package org.cloudfoundry.dependency.in;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.OutputUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.Exceptions;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.Collections;

@Component
@Profile("in")
final class InAction implements CommandLineRunner {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    private final Path destination;

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final InRequest request;

    InAction(Path destination, HttpClient httpClient, ObjectMapper objectMapper, InRequest request) {
        this.destination = destination;
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    public void run(String... args) {
        run()
            .doOnNext(response -> this.logger.debug("Response: {}", response))
            .doOnNext(OutputUtils.write(this.objectMapper))
            .block(Duration.ofMinutes(5));
    }

    Mono<InResponse> run() {
        return getUri()
            .then(this::requestArchive)
            .then(this::writeArchive)
            .then(this::writeVersion)
            .then(this::createOutput);
    }

    private Mono<InResponse> createOutput() {
        return Mono.just(new InResponse(Collections.emptyList(), this.request.getVersion()));
    }

    private Path getArchiveFile() {
        return this.destination.resolve(String.format("%s-%s.jar", this.request.getSource().getArtifactId().get(), this.request.getVersion().getRef()));
    }

    private Mono<String> getUri() {
        return Mono.when(
            Mono.justOrEmpty(this.request.getSource().getGroupId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Group ID must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getArtifactId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Artifact ID must be specified"))))
            .map(tuple -> {
                String groupId = tuple.getT1();
                String artifactId = tuple.getT2();
                String version = this.request.getVersion().getRef();

                return String.format("https://repo1.maven.org/maven2/%s/%s/%s/%s-%s.jar", groupId.replaceAll("\\.", "/"), artifactId, version, artifactId, version);
            });
    }

    private Path getVersionFile() {
        return this.destination.resolve("version");
    }

    private Mono<InputStream> requestArchive(String uri) {
        return this.httpClient.get(uri)
            .then(response -> response.receive().aggregate().asInputStream());
    }

    private Mono<Void> writeArchive(InputStream content) {
        try (InputStream in = content) {
            Files.createDirectories(this.destination);
            Files.copy(in, getArchiveFile(), StandardCopyOption.REPLACE_EXISTING);
            return Mono.empty();
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

    private Mono<Void> writeVersion() {
        try (InputStream in = new ByteArrayInputStream(this.request.getVersion().getRef().getBytes(Charset.defaultCharset()))) {
            Files.createDirectories(this.destination);
            Files.copy(in, getVersionFile(), StandardCopyOption.REPLACE_EXISTING);
            return Mono.empty();
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

}
