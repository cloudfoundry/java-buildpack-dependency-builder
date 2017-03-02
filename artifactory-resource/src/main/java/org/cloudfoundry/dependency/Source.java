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

package org.cloudfoundry.dependency;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Optional;


public final class Source {

    private final Optional<String> artifactId;

    private final Optional<String> artifactPattern;

    private final Optional<String> groupId;

    private final Optional<String> repository;

    private final Optional<String> uri;

    @JsonCreator
    public Source(@JsonProperty("artifact_id") Optional<String> artifactId, @JsonProperty("artifact_pattern") Optional<String> artifactPattern, @JsonProperty("group_id") Optional<String> groupId,
                  @JsonProperty("repository") Optional<String> repository, @JsonProperty("uri") Optional<String> uri) {

        this.artifactId = artifactId;
        this.artifactPattern = artifactPattern;
        this.groupId = groupId;
        this.repository = repository;
        this.uri = uri;
    }

    public Optional<String> getArtifactId() {
        return this.artifactId;
    }

    public Optional<String> getArtifactPattern() {
        return this.artifactPattern;
    }

    public Optional<String> getGroupId() {
        return this.groupId;
    }

    public Optional<String> getRepository() {
        return this.repository;
    }

    public Optional<String> getUri() {
        return this.uri;
    }

}
