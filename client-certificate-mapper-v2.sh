#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat client-certificate-mapper-archives-v2/version)

cp client-certificate-mapper-archives-v2/java-buildpack-client-certificate-mapper-*.jar repository/client-certificate-mapper-$VERSION.jar
cp client-certificate-mapper-archives-v2/version repository/version
