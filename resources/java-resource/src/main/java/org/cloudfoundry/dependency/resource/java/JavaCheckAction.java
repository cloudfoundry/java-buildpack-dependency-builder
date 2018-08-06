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

package org.cloudfoundry.dependency.resource.java;

import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class JavaCheckAction extends CheckAction {

    private final HttpClient httpClient;

    private final JavaCheckRequest request;

    JavaCheckAction(JavaCheckRequest request, OutputUtils outputUtils, HttpClient httpClient) {
        super(request, outputUtils);
        this.httpClient = httpClient;
        this.request = request;
    }

    @Override
    protected Flux<String> doRun() {
        String directoryUri = getDirectoryUri();

        return requestDirectoryPayload(directoryUri)
            .flatMapMany(this::extractReleaseUri)
            .flatMap(this::requestReleasePayload)
            .flatMap(this::getCandidateVersions);
    }

    private Flux<String> extractReleaseUri(Document payload) {
        return Flux.fromIterable(payload.select("table.innerPgSignpost"))
            .flatMapIterable(table -> table.select("li"))
            .filter(element -> element.text().contains("(public release)"))
            .flatMapIterable(item -> item.select("a[href]"))
            .map(element -> UriComponentsBuilder.fromUriString(getDirectoryUri()).replacePath(element.attr("href")).toUriString());
    }

    private Flux<String> getCandidateVersions(String payload) {
        return Flux.just(payload)
            .transform(this::validVersions);
    }

    private String getDirectoryUri() {
        return this.request.getSource().getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
    }

    private Pattern getVersionFilter() {
        return this.request.getSource().getVersionFilter()
            .map(Pattern::compile)
            .orElseThrow(() -> new IllegalArgumentException("Version pattern must be specified"));
    }

    private Mono<Document> requestDirectoryPayload(String uri) {
        return this.httpClient.get(uri)
            .flatMap(response -> response.receive().aggregate().asString())
            .map(Jsoup::parse);
    }

    private Mono<String> requestReleasePayload(String uri) {
        return this.httpClient.get(uri)
            .flatMap(response -> response.receive().aggregate().asString());
    }

    private Flux<String> validVersions(Flux<String> versions) {
        Pattern versionFilter = getVersionFilter();

        return versions
            .map(versionFilter::matcher)
            .filter(Matcher::find)
            .map(matcher -> String.format("%s.%s.%s-%d", matcher.group(1), matcher.group(2), matcher.group(3), Integer.parseInt(matcher.group(4))));
    }

}
