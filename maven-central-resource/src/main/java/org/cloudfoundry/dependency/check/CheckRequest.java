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

package org.cloudfoundry.dependency.check;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.cloudfoundry.dependency.Source;
import org.cloudfoundry.dependency.Version;

import java.util.Objects;
import java.util.Optional;

final class CheckRequest {

    private final Source source;

    private final Optional<Version> version;

    CheckRequest(@JsonProperty("source") Source source, @JsonProperty("version") Optional<Version> version) {
        this.source = source;
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
        CheckRequest request = (CheckRequest) o;
        return Objects.equals(source, request.source) &&
            Objects.equals(version, request.version);
    }

    @Override
    public int hashCode() {
        return Objects.hash(source, version);
    }

    @Override
    public String toString() {
        return "CheckRequest{" +
            "source=" + source +
            ", version=" + version +
            '}';
    }

    Source getSource() {
        return this.source;
    }

    Optional<Version> getVersion() {
        return this.version;
    }

}
