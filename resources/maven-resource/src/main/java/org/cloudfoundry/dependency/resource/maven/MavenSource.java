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

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.stereotype.Component;

import java.util.Optional;

final class MavenSource {

    private final Optional<String> artifactId;

    private final Optional<String> classifier;

    private final Optional<String> groupId;

    private final Optional<String> packaging;

    private final Optional<String> uri;

    private final Optional<String> versionPattern;

    @JsonCreator
    MavenSource(@JsonProperty("artifact_id") Optional<String> artifactId,
                @JsonProperty("classifier") Optional<String> classifier,
                @JsonProperty("group_id") Optional<String> groupId,
                @JsonProperty("packaging") Optional<String> packaging,
                @JsonProperty("uri") Optional<String> uri,
                @JsonProperty("version_pattern") Optional<String> versionPattern) {

        this.artifactId = artifactId;
        this.classifier = classifier;
        this.groupId = groupId;
        this.packaging = packaging;
        this.uri = uri;
        this.versionPattern = versionPattern;
    }

    Optional<String> getArtifactId() {
        return this.artifactId;
    }

    Optional<String> getClassifier() {
        return this.classifier;
    }

    Optional<String> getGroupId() {
        return this.groupId;
    }

    Optional<String> getPackaging() {
        return this.packaging;
    }

    Optional<String> getUri() {
        return this.uri;
    }

    Optional<String> getVersionPattern() {
        return this.versionPattern;
    }

}
