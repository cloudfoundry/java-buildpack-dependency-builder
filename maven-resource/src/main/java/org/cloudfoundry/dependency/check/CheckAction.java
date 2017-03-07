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

package org.cloudfoundry.dependency.check;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.cloudfoundry.dependency.OutputUtils;
import org.cloudfoundry.dependency.VersionHolder;
import org.cloudfoundry.dependency.VersionReference;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.SAXException;
import reactor.core.Exceptions;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class CheckAction implements CommandLineRunner {

    private static final XPathExpression VERSIONS;

    static {
        try {
            VERSIONS = XPathFactory.newInstance().newXPath().compile("/metadata/versioning/versions/version/text()");
        } catch (XPathExpressionException e) {
            throw Exceptions.propagate(e);
        }
    }

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    private final HttpClient httpClient;

    private final ObjectMapper objectMapper;

    private final CheckRequest request;

    CheckAction(HttpClient httpClient, ObjectMapper objectMapper, CheckRequest request) {
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    public void run(String... args) {
        run()
            .doOnNext(response -> this.logger.debug("Response: {}", response))
            .doOnNext(OutputUtils.write(this.objectMapper))
            .block(Duration.ofMinutes(5));
    }

    Mono<List<VersionReference>> run() {
        return getUri()
            .then(this::requestPayload)
            .flatMap(this::getCandidateVersions)
            .transform(this::sinceVersion)
            .map(version -> new VersionReference(version.getRaw()))
            .collectList();
    }

    private Flux<String> filteredVersions(Flux<String> versions) {
        return this.request.getSource().getVersionPattern()
            .map(filter -> versions
                .filter(Pattern.compile(filter).asPredicate()))
            .orElse(versions);
    }

    private Flux<VersionHolder> getCandidateVersions(Document payload) {
        return Mono.fromCallable(() -> VERSIONS.evaluate(payload, XPathConstants.NODESET))
            .cast(NodeList.class)
            .flatMap(nodes -> {
                List<Node> versions = new ArrayList<>(nodes.getLength());

                for (int i = 0; i < nodes.getLength(); i++) {
                    versions.add(nodes.item(i));
                }

                return Flux.fromIterable(versions);
            })
            .cast(Text.class)
            .map(Text::getWholeText)
            .transform(this::filteredVersions)
            .map(VersionHolder::new)
            .sort();
    }

    private Mono<String> getUri() {
        return Mono.when(
            Mono.justOrEmpty(this.request.getSource().getUri())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("URI must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getGroupId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Group ID must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getArtifactId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Artifact ID must be specified"))))
            .map(tuple -> {
                String uri = tuple.getT1();
                String groupId = tuple.getT2();
                String artifactId = tuple.getT3();

                StringBuilder sb = new StringBuilder(uri);
                sb.append("/").append(groupId.replaceAll("\\.", "/"));
                sb.append("/").append(artifactId);
                sb.append("/maven-metadata.xml");

                return sb.toString();
            });
    }

    @SuppressWarnings("unchecked")
    private Mono<Document> requestPayload(String uri) {
        return this.httpClient.get(uri)
            .then(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try (InputStream in = content) {
                    return DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(in);
                } catch (IOException | ParserConfigurationException | SAXException e) {
                    throw Exceptions.propagate(e);
                }
            });
    }

    private Flux<VersionHolder> sinceVersion(Flux<VersionHolder> versions) {
        return this.request.getVersion()
            .map(version -> {
                VersionHolder previous = new VersionHolder(version.getRef());

                return versions
                    .filter(previous::lessThanOrEqualTo);
            })
            .orElseGet(() -> versions.takeLast(1));
    }

}
