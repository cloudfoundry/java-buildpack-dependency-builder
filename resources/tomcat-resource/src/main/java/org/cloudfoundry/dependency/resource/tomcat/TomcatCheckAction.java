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

package org.cloudfoundry.dependency.resource.tomcat;

import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class TomcatCheckAction extends CheckAction {

    private static final Pattern VERSION = Pattern.compile("^v(.+)/$");

    private final HttpClient httpClient;

    private final TomcatCheckRequest request;

    TomcatCheckAction(TomcatCheckRequest request, OutputUtils outputUtils, HttpClient httpClient) {
        super(request, outputUtils);
        this.httpClient = httpClient;
        this.request = request;
    }

    @Override
    protected Flux<String> doRun() {
        String directoryUri = getDirectoryUri();

        return requestPayload(directoryUri)
            .flatMapMany(this::getCandidateVersions);
    }

    private Flux<String> filteredVersions(Flux<String> versions) {
        return this.request.getSource().getVersionFilter()
            .map(filter -> versions
                .filter(Pattern.compile(filter).asPredicate()))
            .orElse(versions);
    }

    private Flux<String> getCandidateVersions(Document payload) {
        return Flux.fromIterable(payload.select("a[href]"))
            .map(Element::text)
            .transform(this::validVersions)
            .transform(this::filteredVersions);
    }

    private String getDirectoryUri() {
        return this.request.getSource().getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
    }

    private Mono<Document> requestPayload(String uri) {
        return this.httpClient.get(uri)
            .flatMap(response -> response.receive().aggregate().asString())
            .map(Jsoup::parse);
    }

    private Flux<String> validVersions(Flux<String> versions) {
        return versions
            .map(VERSION::matcher)
            .filter(Matcher::find)
            .map(matcher -> matcher.group(1));
    }

}
