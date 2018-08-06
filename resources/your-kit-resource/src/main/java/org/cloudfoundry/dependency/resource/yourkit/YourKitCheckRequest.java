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

package org.cloudfoundry.dependency.resource.yourkit;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.cloudfoundry.dependency.resource.CheckRequest;
import org.cloudfoundry.dependency.resource.VersionReference;

import java.util.Optional;

final class YourKitCheckRequest extends CheckRequest<YourKitSource> {

    YourKitCheckRequest(@JsonProperty("source") YourKitSource source, @JsonProperty("version") Optional<VersionReference> version) {
        super(source, version);
    }

}
