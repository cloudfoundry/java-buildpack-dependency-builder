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

package org.cloudfoundry.dependency.resource.java;

import org.cloudfoundry.dependency.resource.ArtifactMetadata;
import org.cloudfoundry.dependency.resource.InAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.cloudfoundry.dependency.resource.VersionHolder;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

@Component
@Profile("in")
final class JavaInAction extends InAction {

    private final JavaInRequest request;

    JavaInAction(Path destination, JavaInRequest request, OutputUtils outputUtils) {
        super(destination, request, outputUtils);
        this.request = request;
    }

    @Override
    protected Flux<ArtifactMetadata> doRun() {
        return Flux.defer(() -> {
            VersionHolder versionHolder = new VersionHolder(this.request.getVersion().getRef());

            writeArtifact("minor_version", getInputStream(versionHolder.getMajor()));
            writeArtifact("update_version", getInputStream(versionHolder.getMinor()));
            writeArtifact("build_number", getInputStream(versionHolder.getMicro()));

            return Flux.empty();
        });
    }

    private InputStream getInputStream(Integer i) {
        return new ByteArrayInputStream(i.toString().getBytes(StandardCharsets.UTF_8));
    }

}
