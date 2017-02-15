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

import org.cloudfoundry.dependency.Source;
import org.cloudfoundry.dependency.Version;
import org.junit.Test;
import reactor.ipc.netty.http.client.HttpClient;
import reactor.test.StepVerifier;

import java.time.Duration;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

public final class CheckActionTest {

    private final HttpClient httpClient = HttpClient.create();

    @Test
    public void noUri() {
        CheckRequest request = new CheckRequest(
            new Source(Optional.empty(), Optional.empty()),
            Optional.empty()
        );

        new CheckAction(this.httpClient, null, request)
            .run()
            .as(StepVerifier::create)
            .expectError(IllegalArgumentException.class)
            .verify(Duration.ofSeconds(5));
    }

    @Test
    public void noVersion() {
        CheckRequest request = new CheckRequest(
            new Source(Optional.of("https://archive.apache.org/dist/tomcat/tomcat-8"), Optional.empty()),
            Optional.empty()
        );

        new CheckAction(this.httpClient, null, request)
            .run()
            .as(StepVerifier::create)
            .assertNext(versions -> assertThat(versions).hasSize(1))
            .expectComplete()
            .verify(Duration.ofSeconds(5));
    }

    @Test
    public void withVersion() {
        CheckRequest request = new CheckRequest(
            new Source(Optional.of("https://archive.apache.org/dist/tomcat/tomcat-8"), Optional.empty()),
            Optional.of(new Version("8.5.8"))
        );

        new CheckAction(this.httpClient, null, request)
            .run()
            .as(StepVerifier::create)
            .assertNext(versions -> assertThat(versions.size()).isGreaterThanOrEqualTo(3))
            .expectComplete()
            .verify(Duration.ofSeconds(5));
    }

    @Test
    public void withVersionFilter() {
        CheckRequest request = new CheckRequest(
            new Source(Optional.of("https://archive.apache.org/dist/tomcat/tomcat-8"), Optional.of("8\\.0\\..*")),
            Optional.of(new Version("8.0.39"))
        );

        new CheckAction(this.httpClient, null, request)
            .run()
            .as(StepVerifier::create)
            .assertNext(versions -> versions.forEach(version -> assertThat(version.getRef()).doesNotStartWith("8.5")))
            .expectComplete()
            .verify(Duration.ofSeconds(5));
    }

}
