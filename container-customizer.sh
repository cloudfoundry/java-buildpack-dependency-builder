#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat container-customizer-archives/version)

cp container-customizer-archives/java-buildpack-container-customizer-*.jar repository/container-customizer-$VERSION.jar
cp container-customizer-archives/version repository/version
