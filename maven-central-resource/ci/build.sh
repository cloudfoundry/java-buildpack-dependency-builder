#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/maven-central-resource
./mvnw -q package
cd -

cp java-buildpack-dependency-builder/maven-central-resource/ci/docker-image/* docker-image
cp java-buildpack-dependency-builder/maven-central-resource/target/maven-central-resource.jar docker-image
