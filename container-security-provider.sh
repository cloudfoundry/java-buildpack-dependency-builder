#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat container-security-provider-archives/version)

cp container-security-provider-archives/java-buildpack-container-security-provider-*.jar repository/container-security-provider-$VERSION.jar
cp container-security-provider-archives/version repository/version
