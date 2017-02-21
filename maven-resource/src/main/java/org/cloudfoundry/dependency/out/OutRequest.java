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

package org.cloudfoundry.dependency.out;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.cloudfoundry.dependency.Source;

import java.util.Map;
import java.util.Objects;

final class OutRequest {

    private final Map<String, Object> params;

    private final Source source;

    OutRequest(@JsonProperty("params") Map<String, Object> params, @JsonProperty("source") Source source) {
        this.params = params;
        this.source = source;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        OutRequest that = (OutRequest) o;
        return Objects.equals(params, that.params) &&
            Objects.equals(source, that.source);
    }

    @Override
    public int hashCode() {
        return Objects.hash(params, source);
    }

    @Override
    public String toString() {
        return "OutRequest{" +
            "params=" + params +
            ", source=" + source +
            '}';
    }

    Map<String, Object> getParams() {
        return this.params;
    }

    Source getSource() {
        return this.source;
    }

}
