#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/resources
./mvnw -q package
cd -

cp -r java-buildpack-dependency-builder/resources/artifactory-resource-docker-image/* artifactory-resource-docker-image
cp -r java-buildpack-dependency-builder/resources/maven-resource-docker-image/* maven-resource-docker-image
cp -r java-buildpack-dependency-builder/resources/pivotal-network-resource-docker-image/* pivotal-network-resource-docker-image
cp -r java-buildpack-dependency-builder/resources/tomcat-resource-docker-image/* tomcat-resource-docker-image
