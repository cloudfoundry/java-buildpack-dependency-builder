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
    public final void run(String... args) throws Exception {
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

    protected final Digests writeArtifact(String artifactName, InputStream content) {
        try (InputStream in = content) {
            Path artifactFile = Files.createDirectories(this.destination).resolve(artifactName);
            Files.copy(in, artifactFile, StandardCopyOption.REPLACE_EXISTING);
            return new Digests(getMd5(artifactFile), getSha1(artifactFile), getSha256(artifactFile), getSha384(artifactFile), getSha512(artifactFile));
        } catch (IOException e) {
            throw Exceptions.propagate(e);
        }
    }

    private String getMd5(Path artifact) throws IOException {
        try (InputStream in = Files.newInputStream(artifact, StandardOpenOption.READ)) {
            return DigestUtils.md5Hex(in);
        }
    }

    private String getSha1(Path artifact) throws IOException {
        try (InputStream in = Files.newInputStream(artifact, StandardOpenOption.READ)) {
            return DigestUtils.sha1Hex(in);
        }
    }

    private String getSha256(Path artifact) throws IOException {
        try (InputStream in = Files.newInputStream(artifact, StandardOpenOption.READ)) {
            return DigestUtils.sha256Hex(in);
        }
    }

    private String getSha384(Path artifact) throws IOException {
        try (InputStream in = Files.newInputStream(artifact, StandardOpenOption.READ)) {
            return DigestUtils.sha384Hex(in);
        }
    }

    private String getSha512(Path artifact) throws IOException {
        try (InputStream in = Files.newInputStream(artifact, StandardOpenOption.READ)) {
            return DigestUtils.sha512Hex(in);
        }
    }

    private List<Metadata> toMetadata(List<ArtifactMetadata> artifacts) {
        if (artifacts.size() == 1) {
            ArtifactMetadata artifactMetadata = artifacts.get(0);
            Digests digests = artifactMetadata.getDigests();

            return Arrays.asList(
                new Metadata("name", artifactMetadata.getName()),
                new Metadata("uri", artifactMetadata.getUri()),
                new Metadata("sha1", digests.getSha1()),
                new Metadata("sha256", digests.getSha256()),
                new Metadata("sha384", digests.getSha384()),
                new Metadata("sha512", digests.getSha512()),
                new Metadata("md5", digests.getMd5()));
        }

        List<Metadata> metadata = new ArrayList<>(artifacts.size() * 7);

        for (int i = 0; i < artifacts.size(); i++) {
            ArtifactMetadata artifactMetadata = artifacts.get(i);
            Digests digests = artifactMetadata.getDigests();

            metadata.add(new Metadata(String.format("[%d] name", i), artifactMetadata.getName()));
            metadata.add(new Metadata(String.format("[%d] uri", i), artifactMetadata.getUri()));
            metadata.add(new Metadata(String.format("[%d] sha1", i), digests.getSha1()));
            metadata.add(new Metadata(String.format("[%d] sha256", i), digests.getSha256()));
            metadata.add(new Metadata(String.format("[%d] sha384", i), digests.getSha384()));
            metadata.add(new Metadata(String.format("[%d] sha512", i), digests.getSha512()));
            metadata.add(new Metadata(String.format("[%d] md5", i), digests.getMd5()));
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
