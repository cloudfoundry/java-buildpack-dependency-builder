#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tc-server-archives/metadata.json | jq -r '.Release.Version')

cp tc-server-archives/pivotal-tc-server-standard-*.tar.gz repository/tc-server-$VERSION.tar.gz
echo $VERSION > repository/version
