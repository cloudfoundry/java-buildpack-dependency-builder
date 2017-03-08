#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/pivotal-network-resource
./mvnw -q package
cd -

cp java-buildpack-dependency-builder/pivotal-network-resource/ci/docker-image/* docker-image
cp java-buildpack-dependency-builder/pivotal-network-resource/target/pivotal-network-resource.jar docker-image
