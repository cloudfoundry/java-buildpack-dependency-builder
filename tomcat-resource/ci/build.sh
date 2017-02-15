#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/tomcat-resource
./mvnw -q package
cd -

cp java-buildpack-dependency-builder/tomcat-resource/ci/docker-image/* docker-image
cp java-buildpack-dependency-builder/tomcat-resource/target/tomcat-resource.jar docker-image
