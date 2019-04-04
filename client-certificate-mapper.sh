#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat client-certificate-mapper-archives/version)

cp client-certificate-mapper-archives/java-buildpack-client-certificate-mapper-*.jar repository/client-certificate-mapper-$VERSION.jar
cp client-certificate-mapper-archives/version repository/version
