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
import org.cloudfoundry.dependency.VersionHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.Exceptions;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;
import reactor.ipc.netty.http.client.HttpClientRequest;

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
        String artifactId = this.request.getSource().getArtifactId()
            .orElseThrow(() -> new IllegalArgumentException("Artifact ID must be specified"));

        StringBuilder sb = new StringBuilder(artifactId).append("-").append(this.request.getVersion().getRef());

        this.request.getSource().getClassifier()
            .ifPresent(classifier -> sb.append("-").append(classifier));

        sb.append(".").append(this.request.getSource().getPackaging().orElse("jar"));

        return this.destination.resolve(sb.toString());
    }

    private Mono<String> getUri() {
        return Mono.when(
            Mono.justOrEmpty(this.request.getSource().getUri())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("URI must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getGroupId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Group ID must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getArtifactId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Artifact ID must be specified"))))
            .map(tuple -> {
                String uri = tuple.getT1();
                String groupId = tuple.getT2();
                String artifactId = tuple.getT3();
                String version = this.request.getVersion().getRef();


                StringBuilder sb = new StringBuilder(uri);
                sb.append("/").append(groupId.replaceAll("\\.", "/"));
                sb.append("/").append(artifactId);
                sb.append("/").append(version);
                sb.append("/").append(artifactId).append("-").append(version);

                this.request.getSource().getClassifier()
                    .ifPresent(classifier -> sb.append("-").append(classifier));

                sb.append(".").append(this.request.getSource().getPackaging().orElse("jar"));

                return sb.toString();
            });
    }

    private Path getVersionFile() {
        return this.destination.resolve("version");
    }

    private Mono<InputStream> requestArchive(String uri) {
        return this.httpClient.get(uri, HttpClientRequest::followRedirect)
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
        try (InputStream in = new ByteArrayInputStream(new VersionHolder(this.request.getVersion().getRef()).toRepositoryVersion().getBytes(Charset.defaultCharset()))) {
            Files.createDirectories(this.destination);
            Files.copy(in, getVersionFile(), StandardCopyOption.REPLACE_EXISTING);
            return Mono.empty();
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

}
