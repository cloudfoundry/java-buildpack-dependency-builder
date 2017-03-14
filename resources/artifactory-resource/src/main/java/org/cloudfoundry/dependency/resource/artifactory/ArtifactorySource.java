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

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Optional;

final class ArtifactorySource {

    private final Optional<String> artifactId;

    private final Optional<String> artifactPattern;

    private final Optional<String> groupId;

    private final Optional<String> repository;

    private final Optional<String> uri;

    @JsonCreator
    ArtifactorySource(@JsonProperty("artifact_id") Optional<String> artifactId,
                      @JsonProperty("artifact_pattern") Optional<String> artifactPattern,
                      @JsonProperty("group_id") Optional<String> groupId,
                      @JsonProperty("repository") Optional<String> repository,
                      @JsonProperty("uri") Optional<String> uri) {

        this.artifactId = artifactId;
        this.artifactPattern = artifactPattern;
        this.groupId = groupId;
        this.repository = repository;
        this.uri = uri;
    }

    Optional<String> getArtifactId() {
        return this.artifactId;
    }

    Optional<String> getArtifactPattern() {
        return this.artifactPattern;
    }

    Optional<String> getGroupId() {
        return this.groupId;
    }

    Optional<String> getRepository() {
        return this.repository;
    }

    Optional<String> getUri() {
        return this.uri;
    }
}
