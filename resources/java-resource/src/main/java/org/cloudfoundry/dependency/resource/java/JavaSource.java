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

package org.cloudfoundry.dependency.resource.java;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Optional;

final class JavaSource {

    private final Optional<String> uri;

    private final Optional<String> versionFilter;

    @JsonCreator
    JavaSource(@JsonProperty("uri") Optional<String> uri, @JsonProperty("version_pattern") Optional<String> versionFilter) {
        this.uri = uri;
        this.versionFilter = versionFilter;
    }

    Optional<String> getUri() {
        return this.uri;
    }

    Optional<String> getVersionFilter() {
        return this.versionFilter;
    }

}
