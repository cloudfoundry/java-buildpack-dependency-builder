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

package org.cloudfoundry.dependency.resource.pivotalnetwork;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.resource.NetworkLogging;
import reactor.core.Exceptions;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;
import reactor.ipc.netty.http.client.HttpClientRequest;

import java.io.IOException;
import java.util.Map;
import java.util.Optional;

final class PivotalNetworkUtils {

    private PivotalNetworkUtils() {
    }

    static HttpClientRequest addAuthorization(Optional<String> apiToken, HttpClientRequest request) {
        return request.addHeader("Authorization",
            String.format("Token %s", apiToken.orElseThrow(() -> new IllegalArgumentException("api_token must be specified"))));
    }

    static String getReleasesUri(Optional<String> product) {
        return String.format("https://network.pivotal.io/api/v2/products/%s/releases",
            product.orElseThrow(() -> new IllegalArgumentException("product must be specified")));
    }

    @SuppressWarnings("unchecked")
    static Mono<Map<String, Object>> requestPayload(Optional<String> apiToken, HttpClient httpClient, ObjectMapper objectMapper, String uri) {
        return httpClient
            .get(uri, request -> addAuthorization(apiToken, request).followRedirect())
            .doOnSubscribe(NetworkLogging.get(uri))
            .transform(NetworkLogging.response(uri))
            .flatMap(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try {
                    return objectMapper.readValue(content, Map.class);
                } catch (IOException e) {
                    throw Exceptions.propagate(e);
                }
            });
    }

}
