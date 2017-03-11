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
import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.ipc.netty.http.client.HttpClient;

import java.util.List;
import java.util.Map;

import static org.cloudfoundry.dependency.resource.pivotalnetwork.PivotalNetworkUtils.getReleasesUri;
import static org.cloudfoundry.dependency.resource.pivotalnetwork.PivotalNetworkUtils.requestPayload;

@Component
@Profile("check")
final class PivotalNetworkCheckAction extends CheckAction {

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final PivotalNetworkCheckRequest request;

    PivotalNetworkCheckAction(PivotalNetworkCheckRequest request, OutputUtils outputUtils, HttpClient httpClient, ObjectMapper objectMapper) {
        super(request, outputUtils);
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    protected Flux<String> doRun() {
        String releasesUri = getReleasesUri(this.request.getSource().getProduct());

        return requestPayload(this.request.getSource().getApiToken(), this.httpClient, this.objectMapper, releasesUri)
            .flatMap(this::getCandidateVersions);
    }

    @SuppressWarnings("unchecked")
    private Flux<String> getCandidateVersions(Map<String, Object> payload) {
        return Flux.fromIterable((List<Map<String, String>>) payload.get("releases"))
            .map(p -> p.get("version"));
    }

}
