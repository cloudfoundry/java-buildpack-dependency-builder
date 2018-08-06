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

package org.cloudfoundry.dependency.resource.artifactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.resource.ArtifactMetadata;
import org.cloudfoundry.dependency.resource.InAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.ipc.netty.http.client.HttpClient;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import static org.cloudfoundry.dependency.resource.CommonUtils.getArtifactName;
import static org.cloudfoundry.dependency.resource.CommonUtils.requestArtifact;
import static org.cloudfoundry.dependency.resource.artifactory.ArtifactoryUtils.filteredArtifacts;
import static org.cloudfoundry.dependency.resource.artifactory.ArtifactoryUtils.requestSearchPayload;

@Component
@Profile("in")
final class ArtifactoryInAction extends InAction {

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final ArtifactoryInRequest request;

    ArtifactoryInAction(Path destination, ArtifactoryInRequest request, OutputUtils outputUtils, HttpClient httpClient, ObjectMapper objectMapper) {
        super(destination, request, outputUtils);
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    protected Flux<ArtifactMetadata> doRun() {
        String searchUri = getSearchUri();

        return requestSearchPayload(this.httpClient, this.objectMapper, searchUri)
            .flatMapMany(this::getCandidateArtifacts)
            .map(this::getArtifactUri)
            .flatMap(artifactUri -> {
                String artifactName = getArtifactName(artifactUri);

                return requestArtifact(this.httpClient, artifactUri)
                    .map(content -> writeArtifact(artifactName, content))
                    .map(sha256 -> new ArtifactMetadata(artifactName, sha256, artifactUri));
            });
    }

    private String getArtifactUri(String path) {
        ArtifactorySource source = this.request.getSource();
        String uri = source.getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
        String repository = source.getRepository().orElseThrow(() -> new IllegalArgumentException("Repository must be specified"));

        return String.format("%s/%s%s", uri, repository, path);
    }

    @SuppressWarnings("unchecked")
    private Flux<String> getCandidateArtifacts(Map<String, Object> payload) {
        return Flux.fromIterable((List<Map<String, String>>) payload.get("results"))
            .map(result -> result.get("path"))
            .transform(paths -> filteredArtifacts(this.request.getSource().getArtifactPattern(), paths));
    }

    private String getSearchUri() {
        ArtifactorySource source = this.request.getSource();
        String uri = source.getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
        String groupId = source.getGroupId().orElseThrow(() -> new IllegalArgumentException("Group ID must be specified"));
        String artifactId = source.getArtifactId().orElseThrow(() -> new IllegalArgumentException("Artifact ID must be specified"));
        String repository = source.getRepository().orElseThrow(() -> new IllegalArgumentException("Repository must be specified"));
        String version = this.request.getVersion().getRef();

        return String.format("%s/api/search/gavc?g=%s&a=%s&v=%s&repos=%s", uri, groupId, artifactId, version, repository);
    }

}
