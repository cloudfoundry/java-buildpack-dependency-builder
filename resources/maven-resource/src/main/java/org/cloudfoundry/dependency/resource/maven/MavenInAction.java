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

package org.cloudfoundry.dependency.resource.maven;

import org.cloudfoundry.dependency.resource.ArtifactMetadata;
import org.cloudfoundry.dependency.resource.InAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.ipc.netty.http.client.HttpClient;

import java.nio.file.Path;

import static org.cloudfoundry.dependency.resource.CommonUtils.getArtifactName;
import static org.cloudfoundry.dependency.resource.CommonUtils.requestArtifact;

@Component
@Profile("in")
final class MavenInAction extends InAction {

    private final HttpClient httpClient;

    private final MavenInRequest request;

    MavenInAction(Path destination, MavenInRequest request, OutputUtils outputUtils, HttpClient httpClient) {
        super(destination, request, outputUtils);
        this.httpClient = httpClient;
        this.request = request;
    }

    @Override
    protected Flux<ArtifactMetadata> doRun() {
        String artifactUri = getArtifactUri();
        String artifactName = getArtifactName(artifactUri);

        return requestArtifact(this.httpClient, artifactUri)
            .map(content -> writeArtifact(artifactName, content))
            .map(digests -> new ArtifactMetadata(digests, artifactName, artifactUri))
            .flux();
    }

    private String getArtifactUri() {
        MavenSource source = this.request.getSource();
        String uri = source.getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
        String groupId = source.getGroupId().orElseThrow(() -> new IllegalArgumentException("Group ID must be specified"));
        String artifactId = source.getArtifactId().orElseThrow(() -> new IllegalArgumentException("Artifact ID must be specified"));
        String packaging = source.getPackaging().orElse("jar");
        String version = this.request.getVersion().getRef();

        StringBuilder sb = new StringBuilder(uri)
            .append("/").append(groupId.replaceAll("\\.", "/"))
            .append("/").append(artifactId)
            .append("/").append(version)
            .append("/").append(artifactId).append("-").append(version);

        source.getClassifier()
            .ifPresent(classifier -> sb.append("-").append(classifier));

        sb.append(".").append(packaging);

        return sb.toString();
    }

}
