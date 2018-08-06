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

package org.cloudfoundry.dependency.resource.yourkit;

import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class YourKitCheckAction extends CheckAction {

    private static final Pattern VERSION = Pattern.compile(".+/YourKit-JavaProfiler-([\\d]{4})\\.([\\d]{2})-b([\\d]+)\\.zip");

    private final HttpClient httpClient;

    YourKitCheckAction(YourKitCheckRequest request, OutputUtils outputUtils, HttpClient httpClient) {
        super(request, outputUtils);
        this.httpClient = httpClient;
    }

    @Override
    protected Flux<String> doRun() {
        String downloadUri = getDownloadUri();

        return requestPayload(downloadUri)
            .flatMapMany(this::getCandidateVersions);
    }

    private Flux<String> getCandidateVersions(Document payload) {
        return Flux.fromIterable(payload.select("a[href]"))
            .map(element -> element.attr("href"))
            .transform(this::validVersions);
    }

    private String getDownloadUri() {
        return "https://www.yourkit.com/download/";
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
            .map(matcher -> String.format("%s.%s.%s", matcher.group(1), matcher.group(2), matcher.group(3)));
    }

}
