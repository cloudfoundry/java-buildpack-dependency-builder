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

package org.cloudfoundry.dependency.resource;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Optional;

public class CheckRequest<S> {

    private final S source;

    private final Optional<VersionReference> version;

    public CheckRequest(@JsonProperty("source") S source, @JsonProperty("version") Optional<VersionReference> version) {
        this.source = source;
        this.version = version;
    }

    public final S getSource() {
        return this.source;
    }

    public final Optional<VersionReference> getVersion() {
        return this.version;
    }

}
