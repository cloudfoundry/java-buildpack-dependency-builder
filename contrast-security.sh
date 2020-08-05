#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat contrast-security-archives/version)

cp contrast-security-archives/java-buildpack-contrast-security-*.jar repository/contrast-security-$VERSION.jar
cp contrast-securityn-archives/version repository/version
