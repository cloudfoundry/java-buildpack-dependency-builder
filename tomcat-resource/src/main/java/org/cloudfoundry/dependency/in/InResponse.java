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

package org.cloudfoundry.dependency.in;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.cloudfoundry.dependency.Metadata;
import org.cloudfoundry.dependency.VersionReference;

import java.util.List;
import java.util.Objects;

final class InResponse {

    private final List<Metadata> metadata;

    private final VersionReference version;

    InResponse(List<Metadata> metadata, VersionReference version) {
        this.metadata = metadata;
        this.version = version;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        InResponse that = (InResponse) o;
        return Objects.equals(metadata, that.metadata) &&
            Objects.equals(version, that.version);
    }

    @Override
    public int hashCode() {
        return Objects.hash(metadata, version);
    }

    @Override
    public String toString() {
        return "InResponse{" +
            "metadata=" + metadata +
            ", version=" + version +
            '}';
    }

    @JsonProperty("metadata")
    List<Metadata> getMetadata() {
        return this.metadata;
    }

    @JsonProperty("version")
    VersionReference getVersion() {
        return this.version;
    }

}
