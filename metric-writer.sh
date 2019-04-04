#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat metric-writer-archives/version)

cp metric-writer-archives/java-buildpack-metric-writer-*.jar repository/metric-writer-$VERSION.jar
cp metric-writer-archives/version repository/version
