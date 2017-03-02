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

    private final Optional<String> groupId;

    private final Optional<String> uri;

    private final Optional<String> versionPattern;

    @JsonCreator
    public Source(@JsonProperty("artifact_id") Optional<String> artifactId, @JsonProperty("group_id") Optional<String> groupId, @JsonProperty("uri") Optional<String> uri,
                  @JsonProperty("version_pattern") Optional<String> versionPattern) {

        this.artifactId = artifactId;
        this.groupId = groupId;
        this.uri = uri;
        this.versionPattern = versionPattern;
    }

    public Optional<String> getArtifactId() {
        return this.artifactId;
    }

    public Optional<String> getGroupId() {
        return this.groupId;
    }

    public Optional<String> getUri() {
        return this.uri;
    }

    public Optional<String> getVersionPattern() {
        return this.versionPattern;
    }

}
