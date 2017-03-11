FROM openjdk:8-jre-alpine

COPY check               /opt/resource/check
COPY in                  /opt/resource/in
COPY out                 /opt/resource/out

RUN chmod +x /opt/resource/*

COPY artifactory-resource.jar /opt/resource/artifactory-resource.jar
