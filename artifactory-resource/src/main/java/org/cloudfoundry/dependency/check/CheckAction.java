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

package org.cloudfoundry.dependency.check;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.OutputUtils;
import org.cloudfoundry.dependency.VersionHolder;
import org.cloudfoundry.dependency.VersionReference;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.Exceptions;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.io.IOException;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class CheckAction implements CommandLineRunner {

    private static final Pattern ARTIFACT = Pattern.compile("^.+/([^/]+)$");

    private static final Pattern VERSION = Pattern.compile("^.+/([^/]+)/[^/]+$");

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final CheckRequest request;

    CheckAction(HttpClient httpClient, ObjectMapper objectMapper, CheckRequest request) {
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

    Mono<List<VersionReference>> run() {
        return getUri()
            .then(this::requestPayload)
            .flatMap(this::getCandidateVersions)
            .transform(this::sinceVersion)
            .map(version -> new VersionReference(version.getRaw()))
            .collectList();
    }

    private Flux<String> filteredArtifacts(Flux<String> paths) {
        return this.request.getSource().getArtifactPattern()
            .map(filter -> {
                Pattern filterPattern = Pattern.compile(filter);

                return paths
                    .filter(path -> {
                        Matcher matcher = ARTIFACT.matcher(path);
                        return matcher.find() && filterPattern.matcher(matcher.group(1)).matches();
                    });
            })
            .orElse(paths);
    }

    private Flux<VersionHolder> getCandidateVersions(Map<String, List<Map<String, String>>> payload) {
        return Mono.just(payload)
            .flatMapIterable(p -> p.get("results"))
            .map(result -> result.get("path"))
            .transform(this::filteredArtifacts)
            .map(path -> {
                Matcher matcher = VERSION.matcher(path);
                if (!matcher.find()) {
                    throw new IllegalArgumentException(String.format("No version specified in %s", path));
                }

                return matcher.group(1);
            })
            .distinct()
            .map(VersionHolder::new)
            .sort();
    }

    private Mono<String> getUri() {
        return Mono.when(
            Mono.justOrEmpty(this.request.getSource().getUri())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("URI must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getGroupId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Group ID must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getArtifactId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Artifact ID must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getRepository())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Repository must be specified"))))
            .map(tuple -> {
                String uri = tuple.getT1();
                String groupId = tuple.getT2();
                String artifactId = tuple.getT3();
                String repository = tuple.getT4();

                return String.format("%s/api/search/gavc?g=%s&a=%s&repos=%s", uri, groupId, artifactId, repository);
            });
    }

    @SuppressWarnings("unchecked")
    private Mono<Map<String, List<Map<String, String>>>> requestPayload(String uri) {
        return this.httpClient.get(uri, request -> request.addHeader("X-Result-Detail", "info"))
            .then(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try {
                    return this.objectMapper.readValue(content, Map.class);
                } catch (IOException e) {
                    throw Exceptions.propagate(e);
                }
            });
    }

    private Flux<VersionHolder> sinceVersion(Flux<VersionHolder> versions) {
        return this.request.getVersion()
            .map(version -> {
                VersionHolder previous = new VersionHolder(version.getRef());

                return versions
                    .filter(previous::lessThanOrEqualTo);
            })
            .orElseGet(() -> versions.takeLast(1));
    }

}
