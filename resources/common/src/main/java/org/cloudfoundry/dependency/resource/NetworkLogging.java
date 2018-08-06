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

import org.reactivestreams.Subscription;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;
import reactor.ipc.netty.http.client.HttpClientResponse;

import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;
import java.util.function.Function;

public final class NetworkLogging {

    private static final Logger LOGGER = LoggerFactory.getLogger("network");

    private static final double MILLISECOND = 1;

    private static final double SECOND = 1000 * MILLISECOND;

    private static final double MINUTE = 60 * SECOND;

    private static final double HOUR = 60 * MINUTE;

    public static Consumer<Subscription> get(String uri) {
        return s -> LOGGER.info("GET  {}", uri);
    }

    public static Consumer<Subscription> post(String uri) {
        return s -> LOGGER.info("POST {}", uri);
    }

    public static Function<Mono<HttpClientResponse>, Mono<HttpClientResponse>> response(String uri) {
        if (!LOGGER.isInfoEnabled()) {
            return inbound -> inbound;
        }

        AtomicLong startTimeHolder = new AtomicLong();
        AtomicReference<HttpClientResponse> responseHolder = new AtomicReference<>();

        return inbound -> inbound
            .doOnSubscribe(s -> startTimeHolder.set(System.currentTimeMillis()))
            .doOnNext(responseHolder::set)
            .doFinally(signalType -> {
                String elapsed = asTime(System.currentTimeMillis() - startTimeHolder.get());
                HttpClientResponse response = responseHolder.get();

                if (response == null) {
                    return;
                }

                LOGGER.info("{}  {} ({})", response.status().code(), uri, elapsed);
            });
    }

    private static String asTime(long elapsed) {
        if (elapsed > HOUR) {
            return String.format("%.1f h", (elapsed / HOUR));
        } else if (elapsed > MINUTE) {
            return String.format("%.1f m", (elapsed / MINUTE));
        } else if (elapsed > SECOND) {
            return String.format("%.1f s", (elapsed / SECOND));
        } else {
            return String.format("%d ms", elapsed);
        }
    }

}
