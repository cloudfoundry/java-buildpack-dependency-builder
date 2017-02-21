#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/maven-resource
./mvnw -q package
cd -

cp java-buildpack-dependency-builder/maven-resource/ci/docker-image/* docker-image
cp java-buildpack-dependency-builder/maven-resource/target/maven-resource.jar docker-image
