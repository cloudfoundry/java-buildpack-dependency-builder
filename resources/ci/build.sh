#!/usr/bin/env sh

set -e

cd java-buildpack-dependency-builder/resources
./mvnw package
