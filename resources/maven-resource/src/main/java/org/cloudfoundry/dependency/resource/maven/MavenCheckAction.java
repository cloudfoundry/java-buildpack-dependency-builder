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

package org.cloudfoundry.dependency.resource.maven;

import org.cloudfoundry.dependency.resource.CheckAction;
import org.cloudfoundry.dependency.resource.OutputUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
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
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

@Component
@Profile("check")
final class MavenCheckAction extends CheckAction {

    private final HttpClient httpClient;

    private final MavenCheckRequest request;

    private final XPathExpression versions = XPathFactory.newInstance().newXPath().compile("/metadata/versioning/versions/version/text()");

    MavenCheckAction(MavenCheckRequest request, OutputUtils outputUtils, HttpClient httpClient) throws XPathExpressionException {
        super(request, outputUtils);
        this.httpClient = httpClient;
        this.request = request;
    }

    @Override
    protected Flux<String> doRun() {
        String mavenMetadataUri = getMavenMetadataUri();

        return requestPayload(mavenMetadataUri)
            .flatMapMany(this::getCandidateVersions)
            .transform(this::filteredVersions);
    }

    private Flux<String> filteredVersions(Flux<String> versions) {
        return this.request.getSource().getVersionPattern()
            .map(filter -> versions
                .filter(Pattern.compile(filter).asPredicate()))
            .orElse(versions);
    }

    private Flux<String> getCandidateVersions(Document payload) {
        try {
            NodeList nodes = (NodeList) this.versions.evaluate(payload, XPathConstants.NODESET);
            List<String> versions = new ArrayList<>(nodes.getLength());

            for (int i = 0; i < nodes.getLength(); i++) {
                versions.add(((Text) nodes.item(i)).getWholeText());
            }

            return Flux.fromIterable(versions);
        } catch (XPathExpressionException e) {
            throw Exceptions.propagate(e);
        }
    }

    private String getMavenMetadataUri() {
        MavenSource source = this.request.getSource();
        String uri = source.getUri().orElseThrow(() -> new IllegalArgumentException("URI must be specified"));
        String groupId = source.getGroupId().orElseThrow(() -> new IllegalArgumentException("Group ID must be specified"));
        String artifactId = source.getArtifactId().orElseThrow(() -> new IllegalArgumentException("Artifact ID must be specified"));

        return String.format("%s/%s/%s/maven-metadata.xml", uri, groupId.replaceAll("\\.", "/"), artifactId);
    }

    @SuppressWarnings("unchecked")
    private Mono<Document> requestPayload(String uri) {
        return this.httpClient.get(uri)
            .flatMap(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try (InputStream in = content) {
                    return DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(in);
                } catch (IOException | ParserConfigurationException | SAXException e) {
                    throw Exceptions.propagate(e);
                }
            });
    }

}
