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
import reactor.core.Exceptions;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.time.Duration;
import java.util.Collections;
import java.util.List;

public class InAction implements CommandLineRunner {

    private final Path destination;

    private final OutputUtils outputUtils;

    private final InRequest<?, ?> request;

    public InAction(Path destination, InRequest<?, ?> request, OutputUtils outputUtils) {
        this.destination = destination;
        this.request = request;
        this.outputUtils = outputUtils;
    }

    @Override
    public final void run(String... args) throws Exception {
        doRun()
            .doOnNext(response -> writeVersion())
            .map(metadata -> new InResponse(metadata, this.request.getVersion()))
            .doOnNext(this.outputUtils::write)
            .block(Duration.ofMinutes(5));
    }

    protected Mono<List<Metadata>> doRun() {
        return Mono.empty();
    }

    protected final void writeArtifact(String artifactName, InputStream content) {
        try (InputStream in = content) {
            Path artifactFile = Files.createDirectories(this.destination).resolve(artifactName);
            Files.copy(in, artifactFile, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

    private void writeVersion() {
        try {
            String version = new VersionHolder(this.request.getVersion().getRef()).toRepositoryVersion();
            Path versionFile = Files.createDirectories(this.destination).resolve("version");
            Files.write(versionFile, Collections.singletonList(version), StandardOpenOption.CREATE, StandardOpenOption.WRITE);
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

}
