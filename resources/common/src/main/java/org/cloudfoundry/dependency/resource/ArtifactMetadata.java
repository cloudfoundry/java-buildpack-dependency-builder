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

package org.cloudfoundry.dependency.resource;

public final class ArtifactMetadata {

    private final Digests digests;

    private final String name;

    private final String uri;

    public ArtifactMetadata(Digests digests, String name, String uri) {
        this.digests = digests;
        this.name = name;
        this.uri = uri;
    }

    public Digests getDigests() {
        return this.digests;
    }

    public String getName() {
        return this.name;
    }

    public String getUri() {
        return this.uri;
    }

}
