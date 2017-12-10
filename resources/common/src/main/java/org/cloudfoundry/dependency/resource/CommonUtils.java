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

package org.cloudfoundry.dependency.resource;

import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;
import reactor.ipc.netty.http.client.HttpClientRequest;

import java.io.InputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class CommonUtils {

    private static final Pattern ARTIFACT = Pattern.compile("^.*/([^/]+)$");

    private CommonUtils() {
    }

    public static String getArtifactName(String uri) {
        Matcher matcher = ARTIFACT.matcher(uri);

        if (!matcher.find()) {
            throw new IllegalStateException(String.format("URI %s does not contain an artifact name", uri));
        }

        return matcher.group(1);
    }

    public static Mono<InputStream> requestArtifact(HttpClient httpClient, String uri) {
        return httpClient
            .get(uri, HttpClientRequest::followRedirect)
            .doOnSubscribe(NetworkLogging.get(uri))
            .transform(NetworkLogging.response(uri))
            .flatMap(response -> response.receive().aggregate().asInputStream());
    }

}
