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

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.boot.CommandLineRunner;
import reactor.core.Exceptions;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
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
    public final void run(String... args) {
        doRun()
            .doOnNext(response -> writeVersion())
            .collectList()
            .map(this::toMetadata)
            .map(metadata -> new InResponse(metadata, this.request.getVersion()))
            .doOnNext(this.outputUtils::write)
            .block(Duration.ofMinutes(5));
    }

    protected Flux<ArtifactMetadata> doRun() {
        return Flux.empty();
    }

    protected final String writeArtifact(String artifactName, InputStream content) {
        try (InputStream in = content) {
            Path artifactFile = Files.createDirectories(this.destination).resolve(artifactName);
            Files.copy(in, artifactFile, StandardCopyOption.REPLACE_EXISTING);
            return getSha256(artifactFile);
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

    private String getSha256(Path artifact) throws IOException {
        try (InputStream in = Files.newInputStream(artifact, StandardOpenOption.READ)) {
            return DigestUtils.sha256Hex(in);
        }
    }

    private List<Metadata> toMetadata(List<ArtifactMetadata> artifacts) {
        if (artifacts.size() == 1) {
            ArtifactMetadata artifactMetadata = artifacts.get(0);

            return Arrays.asList(
                new Metadata("name", artifactMetadata.getName()),
                new Metadata("sha256", artifactMetadata.getSha256()),
                new Metadata("uri", artifactMetadata.getUri()));
        }

        List<Metadata> metadata = new ArrayList<>(artifacts.size() * 3);

        for (int i = 0; i < artifacts.size(); i++) {
            ArtifactMetadata artifactMetadata = artifacts.get(i);

            metadata.add(new Metadata(String.format("[%d] name", i), artifactMetadata.getName()));
            metadata.add(new Metadata(String.format("[%d] uri", i), artifactMetadata.getUri()));
            metadata.add(new Metadata(String.format("[%d] sha256", i), artifactMetadata.getSha256()));
        }

        return metadata;
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
