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
import org.cloudfoundry.dependency.resource.ArtifactMetadata;
import org.cloudfoundry.dependency.resource.CommonUtils;
import org.cloudfoundry.dependency.resource.InAction;
import org.cloudfoundry.dependency.resource.NetworkLogging;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.NettyInbound;
import reactor.ipc.netty.http.client.HttpClient;

import java.io.InputStream;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

import static org.cloudfoundry.dependency.resource.pivotalnetwork.PivotalNetworkUtils.addAuthorization;
import static org.cloudfoundry.dependency.resource.pivotalnetwork.PivotalNetworkUtils.getReleasesUri;
import static org.cloudfoundry.dependency.resource.pivotalnetwork.PivotalNetworkUtils.requestPayload;

@Component
@Profile("in")
final class PivotalNetworkInAction extends InAction {

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final PivotalNetworkInRequest request;

    PivotalNetworkInAction(Path destination, PivotalNetworkInRequest request, OutputUtils outputUtils, HttpClient httpClient, ObjectMapper objectMapper) {
        super(destination, request, outputUtils);
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    protected Flux<ArtifactMetadata> doRun() {
        Optional<String> apiToken = this.request.getSource().getApiToken();
        String releasesUri = getReleasesUri(this.request.getSource().getProduct());

        return requestPayload(apiToken, this.httpClient, this.objectMapper, releasesUri)
            .then(this::getReleaseUri)
            .then(releaseUri -> requestPayload(apiToken, this.httpClient, this.objectMapper, releaseUri))
            .flatMap(payload -> {
                String eulaAcceptanceUri = getEulaAcceptanceUri(payload);

                return requestEulaAcceptance(apiToken, eulaAcceptanceUri)
                    .thenMany(getCandidateArchives(payload));
            })
            .flatMap(payload -> {
                String artifactUri = getArtifactUri(payload);
                String artifactName = getArtifactName(payload);

                return requestArtifact(apiToken, artifactUri)
                    .map(content -> writeArtifact(artifactName, content))
                    .map(digests -> new ArtifactMetadata(digests, artifactName, artifactUri));
            });
    }

    private Flux<Map<String, Object>> filteredArtifacts(Optional<String> artifactPattern, Flux<Map<String, Object>> productFiles) {
        return artifactPattern
            .map(filter -> {
                Pattern filterPattern = Pattern.compile(filter);

                return productFiles
                    .filter(productFile -> filterPattern.matcher(getArtifactName(productFile)).matches());
            })
            .orElse(productFiles);
    }

    private String getArtifactName(Map<String, Object> payload) {
        return CommonUtils.getArtifactName((String) payload.get("aws_object_key"));
    }

    @SuppressWarnings("unchecked")
    private String getArtifactUri(Map<String, Object> payload) {
        return ((Map<String, Map<String, String>>) payload.get("_links")).get("download").get("href");
    }

    @SuppressWarnings("unchecked")
    private Flux<Map<String, Object>> getCandidateArchives(Map<String, Object> payload) {
        return Flux.fromIterable((List<Map<String, List<Map<String, Object>>>>) payload.get("file_groups"))
            .flatMapIterable(p -> p.get("product_files"))
            .transform(productFiles -> filteredArtifacts(this.request.getSource().getArtifactPattern(), productFiles));
    }

    @SuppressWarnings("unchecked")
    private String getEulaAcceptanceUri(Map<String, Object> payload) {
        return ((Map<String, Map<String, String>>) payload.get("_links")).get("eula_acceptance").get("href");
    }

    @SuppressWarnings("unchecked")
    private Mono<String> getReleaseUri(Map<String, Object> payload) {
        return Flux.fromIterable((List<Map<String, Object>>) payload.get("releases"))
            .filter(p -> this.request.getVersion().getRef().equals(p.get("version")))
            .single()
            .map(p -> (Map<String, Map<String, String>>) p.get("_links"))
            .map(p -> p.get("self").get("href"));
    }

    private Mono<InputStream> requestArtifact(Optional<String> apiToken, String uri) {
        return httpClient
            .get(uri, request -> addAuthorization(apiToken, request).followRedirect())
            .doOnSubscribe(NetworkLogging.get(uri))
            .transform(NetworkLogging.response(uri))
            .then(response -> response.receive().aggregate().asInputStream());
    }

    private Mono<Void> requestEulaAcceptance(Optional<String> apiToken, String uri) {
        return this.httpClient
            .post(uri, request -> addAuthorization(apiToken, request).followRedirect().send())
            .doOnSubscribe(NetworkLogging.post(uri))
            .transform(NetworkLogging.response(uri))
            .flatMap(NettyInbound::receive)
            .then();
    }

}
