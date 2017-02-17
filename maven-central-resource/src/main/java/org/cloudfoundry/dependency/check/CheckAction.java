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
import org.cloudfoundry.dependency.Version;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import reactor.core.Exceptions;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClient;
import reactor.util.function.Tuple2;
import reactor.util.function.Tuples;

import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Component
@Profile("check")
final class CheckAction implements CommandLineRunner {

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

    Mono<List<Version>> run() {
        return getUri()
            .then(this::requestPayload)
            .flatMap(this::getCandidateVersions)
            .transform(this::sinceVersion)
            .map(version -> new org.cloudfoundry.dependency.Version(version.getRaw()))
            .collectList();
    }

    private Flux<VersionHolder> getCandidateVersions(Map<String, Map<String, List<Map<String, String>>>> payload) {
        return Flux.fromIterable(payload.get("response").get("docs"))
            .map(d -> d.get("v"))
            .map(VersionHolder::new)
            .sort();
    }

    private Mono<String> getUri() {
        return Mono.when(
            Mono.justOrEmpty(this.request.getSource().getGroupId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Group ID must be specified"))),
            Mono.justOrEmpty(this.request.getSource().getArtifactId())
                .otherwiseIfEmpty(Mono.error(new IllegalArgumentException("Artifact ID must be specified"))))
            .map(tuple -> {
                String groupId = tuple.getT1();
                String artifactId = tuple.getT2();
                return String.format("http://search.maven.org/solrsearch/select?q=g:%%22%s%%22%%20AND%%20a:%%22%s%%22&core=gav&rows=1000&wt=json", groupId, artifactId);
            });
    }

    @SuppressWarnings("unchecked")
    private Mono<Map<String, Map<String, List<Map<String, String>>>>> requestPayload(String uri) {
        return this.httpClient.get(uri)
            .then(response -> response.receive().aggregate().asInputStream())
            .map(content -> {
                try (InputStream in = content) {
                    return this.objectMapper.readValue(in, Map.class);
                } catch (IOException e) {
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

    private static final class VersionHolder implements Comparable<VersionHolder> {

        private static final Pattern MAJOR_OR_MINOR = Pattern.compile("^([^\\.-]+)(?:[\\.-](.*))?");

        private static final Pattern MICRO_AND_QUALIFIER = Pattern.compile("^([^\\.-]+)(?:[\\.-](.*))?");

        private final String raw;

        private final com.github.zafarkhaja.semver.Version semver;

        private VersionHolder(String raw) {
            this.raw = raw;
            this.semver = parse(raw);
        }

        @Override
        public int compareTo(VersionHolder o) {
            return this.semver.compareTo(o.getSemver());
        }

        private static Tuple2<Integer, String> majorOrMinorAndTail(String s) {
            if (s.isEmpty()) {
                return Tuples.of(0, s);
            }

            Matcher matcher = MAJOR_OR_MINOR.matcher(s);
            if (!matcher.find()) {
                throw new IllegalArgumentException("Invalid Version");
            }

            return Tuples.of(Integer.parseInt(matcher.group(1)), matcher.group(2));
        }

        private static Tuple2<Integer, String> microAndQualifier(String s) {
            if (s == null || s.isEmpty()) {
                return Tuples.of(0, s);
            }

            Matcher matcher = MICRO_AND_QUALIFIER.matcher(s);
            if (!matcher.find()) {
                throw new IllegalArgumentException("Invalid Version");
            }

            return Tuples.of(Integer.parseInt(matcher.group(1)), matcher.group(2));
        }

        private static com.github.zafarkhaja.semver.Version parse(String raw) {
            StringTokenizer stringTokenizer = new StringTokenizer(raw, ".-");

            Queue<String> tokens = new LinkedList<>();
            while (stringTokenizer.hasMoreElements()) {
                tokens.add(stringTokenizer.nextToken());
            }

            Integer major;
            try {
                major = Integer.parseInt(tokens.peek());
                tokens.remove();
            } catch (NumberFormatException e) {
                major = 0;
            }

            Integer minor;
            try {
                minor = Integer.parseInt(tokens.peek());
                tokens.remove();
            } catch (NumberFormatException e) {
                minor = 0;
            }

            Integer micro;
            try {
                micro = Integer.parseInt(tokens.peek());
                tokens.remove();
            } catch (NumberFormatException e) {
                micro = 0;
            }

            String qualifier = tokens.stream().collect(Collectors.joining());

            try {
                com.github.zafarkhaja.semver.Version version = com.github.zafarkhaja.semver.Version.forIntegers(major, minor, micro);

                if (qualifier != null && !qualifier.isEmpty()) {
                    version.setPreReleaseVersion(qualifier);
                }

                return version;
            } catch (Exception e) {
                throw new IllegalArgumentException("Invalid version " + raw, e);
            }
        }

        private String getRaw() {
            return this.raw;
        }

        private com.github.zafarkhaja.semver.Version getSemver() {
            return this.semver;
        }

        private boolean lessThanOrEqualTo(VersionHolder other) {
            return this.semver.lessThanOrEqualTo(other.getSemver());
        }

    }

}
