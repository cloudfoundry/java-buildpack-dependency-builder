#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/artifactory-resource
./mvnw -q package
cd -

cp java-buildpack-dependency-builder/artifactory-resource/ci/docker-image/* docker-image
cp java-buildpack-dependency-builder/artifactory-resource/target/artifactory-resource.jar docker-image
