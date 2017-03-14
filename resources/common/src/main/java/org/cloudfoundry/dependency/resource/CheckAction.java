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

import org.springframework.boot.CommandLineRunner;
import reactor.core.publisher.Flux;

import java.time.Duration;
import java.util.Optional;

public class CheckAction implements CommandLineRunner {

    private final OutputUtils outputUtils;

    private final CheckRequest<?> request;

    public CheckAction(CheckRequest<?> request, OutputUtils outputUtils) {
        this.request = request;
        this.outputUtils = outputUtils;
    }

    @Override
    public final void run(String... args) {
        doRun()
            .transform(candidateVersions -> getValidVersions(candidateVersions, this.request.getVersion()))
            .collectList()
            .doOnNext(this.outputUtils::write)
            .block(Duration.ofMinutes(5));
    }

    protected Flux<String> doRun() {
        return Flux.empty();
    }

    private static Flux<VersionReference> getValidVersions(Flux<String> candidateVersions, Optional<VersionReference> previousVersion) {
        return candidateVersions
            .map(VersionHolder::new)
            .sort()
            .transform(versions -> sinceVersion(versions, previousVersion))
            .map(version -> new VersionReference(version.getRaw()));
    }

    private static Flux<VersionHolder> sinceVersion(Flux<VersionHolder> versions, Optional<VersionReference> previousVersion) {
        return previousVersion
            .map(version -> {
                VersionHolder previous = new VersionHolder(version.getRef());

                return versions
                    .filter(previous::lessThanOrEqualTo);
            })
            .orElseGet(() -> versions.takeLast(1));
    }

}
