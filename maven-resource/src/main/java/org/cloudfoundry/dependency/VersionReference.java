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

import java.util.Objects;

public final class VersionReference {

    private final String ref;

    @JsonCreator
    public VersionReference(@JsonProperty("ref") String ref) {
        this.ref = ref;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        VersionReference version = (VersionReference) o;
        return Objects.equals(ref, version.ref);
    }

    @JsonProperty("ref")
    public String getRef() {
        return this.ref;
    }

    @Override
    public int hashCode() {
        return Objects.hash(ref);
    }

    @Override
    public String toString() {
        return "VersionReference{" +
            "ref='" + ref + '\'' +
            '}';
    }

}
