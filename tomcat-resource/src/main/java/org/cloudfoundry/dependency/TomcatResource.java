package org.cloudfoundry.dependency;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.deser.DeserializationProblemHandler;
import com.fasterxml.jackson.datatype.jdk8.Jdk8Module;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import reactor.ipc.netty.http.client.HttpClient;

import java.io.IOException;

@SpringBootApplication
public class TomcatResource {

    public static void main(String[] args) throws IOException, InterruptedException {
        SpringApplication.run(TomcatResource.class, args);
    }

    @Bean
    @Profile({"check", "in"})
    HttpClient httpClient() {
        return HttpClient.create();
    }

    @Bean
    ObjectMapper objectMapper() {
        return new ObjectMapper()
            .addHandler(new LoggingDeserializationProblemHandler())
            .registerModule(new Jdk8Module());
    }

    private static final class LoggingDeserializationProblemHandler extends DeserializationProblemHandler {

        private final Logger logger = LoggerFactory.getLogger(LoggingDeserializationProblemHandler.class);

        @Override
        public boolean handleUnknownProperty(DeserializationContext ctxt, JsonParser p, JsonDeserializer<?> deserializer, Object beanOrClass, String propertyName) throws IOException {
            this.logger.warn("{} is an unnecessary configuration parameter", propertyName);
            p.skipChildren();
            return true;
        }

    }

}
