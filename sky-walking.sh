#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat sky-walking-archives/version)

cp sky-walking-archives/apache-skywalking-java-agent-*.tar.gz repository/sky-walking-$VERSION.tar.gz
cp sky-walking-archives/version repository/version
