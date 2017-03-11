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

package org.cloudfoundry.dependency.resource.artifactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.ipc.netty.http.client.HttpClient;

import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.cloudfoundry.dependency.resource.artifactory.ArtifactoryUtils.filteredArtifacts;
import static org.cloudfoundry.dependency.resource.artifactory.ArtifactoryUtils.requestSearchPayload;

@Component
@Profile("check")
final class ArtifactoryCheckAction extends CheckAction {

    private static final Pattern VERSION = Pattern.compile("^.+/([^/]+)/[^/]+$");

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final ArtifactoryCheckRequest request;

    ArtifactoryCheckAction(ArtifactoryCheckRequest request, OutputUtils outputUtils, HttpClient httpClient, ObjectMapper objectMapper) {
        super(request, outputUtils);
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    protected Flux<String> doRun() {
        String searchUri = getSearchUri();

        return requestSearchPayload(this.httpClient, this.objectMapper, searchUri)
            .flatMap(this::getCandidateVersions);
    }

    private String extractVersion(String path) {
        Matcher matcher = VERSION.matcher(path);

        if (!matcher.find()) {
            throw new IllegalArgumentException(String.format("No version specified in %s", path));
        }

        return matcher.group(1);
    }

    @SuppressWarnings("unchecked")
    private Flux<String> getCandidateVersions(Map<String, Object> payload) {
        return Flux.fromIterable((List<Map<String, String>>) payload.get("results"))
            .map(result -> result.get("path"))
            .transform(paths -> filteredArtifacts(this.request.getSource().getArtifactPattern(), paths))
            .map(this::extractVersion)
            .distinct();
    }

    private String getSearchUri() {
        ArtifactorySource source = this.request.getSource();
        String uri = source.getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
        String groupId = source.getGroupId().orElseThrow(() -> new IllegalArgumentException("Group ID must be specified"));
        String artifactId = source.getArtifactId().orElseThrow(() -> new IllegalArgumentException("Artifact ID must be specified"));
        String repository = source.getRepository().orElseThrow(() -> new IllegalArgumentException("Repository must be specified"));

        return String.format("%s/api/search/gavc?g=%s&a=%s&repos=%s", uri, groupId, artifactId, repository);
    }

}
