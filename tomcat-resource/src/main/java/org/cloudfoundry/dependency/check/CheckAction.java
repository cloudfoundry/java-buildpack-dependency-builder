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
import org.cloudfoundry.dependency.Version;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.time.Duration;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class CheckAction implements CommandLineRunner {

    private static final Pattern VERSION = Pattern.compile("^v(.+)/$");

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

    Mono<List<Version>> run() {
        return getUri()
            .then(this::requestDirectoryListing)
            .flatMap(this::getCandidateVersions)
            .transform(this::sinceVersion)
            .map(version -> new org.cloudfoundry.dependency.Version(version.toString()))
            .collectList();
    }

    private Flux<String> filteredVersions(Flux<String> versions) {
        return this.request.getSource().getVersionFilter()
            .map(filter -> versions
                .filter(Pattern.compile(filter).asPredicate()))
            .orElse(versions);
    }

    private Flux<com.github.zafarkhaja.semver.Version> getCandidateVersions(String response) {
        return Mono.just(Jsoup.parse(response))
            .flatMapIterable(d -> d.select("a[href]"))
            .map(Element::text)
            .transform(this::validVersions)
            .transform(this::filteredVersions)
            .map(com.github.zafarkhaja.semver.Version::valueOf)
            .sort();
    }

    private Mono<String> getUri() {
        return Mono.justOrEmpty(this.request.getSource().getUri())
            .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("URI must be specified")));
    }

    private Mono<String> requestDirectoryListing(String uri) {
        return this.httpClient.get(uri)
            .then(response -> response.receive().aggregate().asString());
    }

    private Flux<com.github.zafarkhaja.semver.Version> sinceVersion(Flux<com.github.zafarkhaja.semver.Version> versions) {
        return this.request.getVersion()
            .map(version -> {
                com.github.zafarkhaja.semver.Version previous = com.github.zafarkhaja.semver.Version.valueOf(version.getRef());

                return versions
                    .filter(previous::lessThanOrEqualTo);
            })
            .orElseGet(() -> versions.takeLast(1));
    }

    private Flux<String> validVersions(Flux<String> versions) {
        return versions
            .map(VERSION::matcher)
            .filter(Matcher::find)
            .map(matcher -> matcher.group(1));
    }

}
