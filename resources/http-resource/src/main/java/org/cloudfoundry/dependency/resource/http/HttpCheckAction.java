/*
 * Copyright 2018 the original author or authors.
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

package org.cloudfoundry.dependency.resource.http;

import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpMethod;
import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

@Component
@Profile("check")
final class HttpCheckAction extends CheckAction {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter
        .ofPattern("uuuu.MM.dd")
        .withZone(ZoneId.of("UTC"));

    private final HttpClient httpClient;

    private final HttpCheckRequest request;

    public HttpCheckAction(HttpCheckRequest request, OutputUtils outputUtils, HttpClient httpClient) {
        super(request, outputUtils);
        this.httpClient = httpClient;
        this.request = request;
    }

    @Override
    protected Flux<String> doRun() {
        return requestLastModified()
            .map(FORMATTER::format)
            .flux();
    }

    private String getUri() {
        return this.request.getSource().getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
    }

    private Mono<Instant> requestLastModified() {
        return this.httpClient.request(HttpMethod.HEAD, getUri(), request -> request)
            .flatMap(response -> Mono.just(response.responseHeaders().getTimeMillis(HttpHeaderNames.LAST_MODIFIED)))
            .map(Instant::ofEpochMilli);
    }
}
