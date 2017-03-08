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
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.NettyInbound;
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
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@Profile("in")
final class InAction implements CommandLineRunner {

    private static final Pattern ARTIFACT = Pattern.compile("^.+/([^/]+)$");

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
        return getReleasesUri()
            .then(this::requestReleasesPayload)
            .then(this::getReleaseUri)
            .then(this::requestReleasePayload)
            .flatMap(payload -> getEulaAcceptanceUri(payload)
                .then(this::requestEulaAcceptance)
                .thenMany(getCandidateArchives(payload)))
            .flatMap(payload -> getArchiveUri(payload)
                .then(this::requestArchive)
                .then(content -> writeArchive(payload, content)))
            .then()
            .then(this::writeVersion)
            .then(this::createOutput);
    }

    private Mono<InResponse> createOutput() {
        return Mono.just(new InResponse(Collections.emptyList(), this.request.getVersion()));
    }

    private Flux<Map<String, Object>> filteredArtifacts(Flux<Map<String, Object>> productFiles) {
        return this.request.getSource().getArtifactPattern()
            .map(filter -> {
                Pattern filterPattern = Pattern.compile(filter);

                return productFiles
                    .filter(productFile -> {
                        Matcher matcher = ARTIFACT.matcher((String) productFile.get("aws_object_key"));
                        return matcher.find() && filterPattern.matcher(matcher.group(1)).matches();
                    });
            })
            .orElse(productFiles);
    }

    private Path getArchiveFile(Map<String, Object> payload) {
        String key = (String) payload.get("aws_object_key");
        Matcher matcher = ARTIFACT.matcher(key);

        if (!matcher.find()) {
            throw new IllegalStateException(String.format("aws_object_key %s does not contain an artifact name", key));
        }

        return this.destination.resolve(matcher.group(1));
    }

    @SuppressWarnings("unchecked")
    private Mono<String> getArchiveUri(Map<String, Object> payload) {
        return Mono.just(((Map<String, Map<String, String>>) payload.get("_links")).get("download").get("href"));
    }

    @SuppressWarnings("unchecked")
    private Flux<Map<String, Object>> getCandidateArchives(Map<String, Object> payload) {

        return Flux.fromIterable((List<Map<String, List<Map<String, Object>>>>) payload.get("file_groups"))
            .flatMapIterable(p -> p.get("product_files"))
            .transform(this::filteredArtifacts);
    }

    @SuppressWarnings("unchecked")
    private Mono<String> getEulaAcceptanceUri(Map<String, Object> payload) {
        return Mono.just(((Map<String, Map<String, String>>) payload.get("_links")).get("eula_acceptance").get("href"));
    }

    @SuppressWarnings("unchecked")
    private Mono<String> getReleaseUri(Map<String, List<Map<String, Object>>> releasesPayload) {
        return Flux.fromIterable(releasesPayload.get("releases"))
            .filter(p -> this.request.getVersion().getRef().equals(p.get("version")))
            .single()
            .map(p -> (Map<String, Map<String, String>>) p.get("_links"))
            .map(p -> p.get("self").get("href"));
    }

    private Mono<String> getReleasesUri() {
        return Mono.justOrEmpty(this.request.getSource().getProduct())
            .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("product must be specified")))
            .map(product -> String.format("https://network.pivotal.io/api/v2/products/%s/releases", product));
    }

    private Path getVersionFile() {
        return this.destination.resolve("version");
    }

    private Mono<InputStream> requestArchive(String uri) {
        return Mono.justOrEmpty(this.request.getSource().getApiToken())
            .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("api_token must be specified")))
            .then(apiToken -> this.httpClient.get(uri, request -> request
                .addHeader("Authorization", String.format("Token %s", apiToken))
                .followRedirect()))
            .then(response -> response.receive().aggregate().asInputStream());
    }

    private Mono<Void> requestEulaAcceptance(String uri) {
        return Mono.justOrEmpty(this.request.getSource().getApiToken())
            .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("api_token must be specified")))
            .then(apiToken -> this.httpClient.post(uri, request -> request.addHeader("Authorization", String.format("Token %s", apiToken)).send()))
            .flatMap(NettyInbound::receive)
            .then();
    }

    @SuppressWarnings("unchecked")
    private Mono<Map<String, Object>> requestReleasePayload(String uri) {
        return Mono.justOrEmpty(this.request.getSource().getApiToken())
            .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("api_token must be specified")))
            .then(apiToken -> this.httpClient.get(uri, request -> request.addHeader("Authorization", String.format("Token %s", apiToken))))
            .then(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try {
                    return this.objectMapper.readValue(content, Map.class);
                } catch (IOException e) {
                    throw Exceptions.propagate(e);
                }
            });
    }

    @SuppressWarnings("unchecked")
    private Mono<Map<String, List<Map<String, Object>>>> requestReleasesPayload(String uri) {
        return Mono.justOrEmpty(this.request.getSource().getApiToken())
            .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("api_token must be specified")))
            .then(apiToken -> this.httpClient.get(uri, request -> request.addHeader("Authorization", String.format("Token %s", apiToken))))
            .then(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try {
                    return this.objectMapper.readValue(content, Map.class);
                } catch (IOException e) {
                    throw Exceptions.propagate(e);
                }
            });
    }

    private Mono<Void> writeArchive(Map<String, Object> payload, InputStream content) {
        try (InputStream in = content) {
            Files.createDirectories(this.destination);
            Files.copy(in, getArchiveFile(payload), StandardCopyOption.REPLACE_EXISTING);
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
