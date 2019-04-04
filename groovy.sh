#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat groovy-archives/version)

cp groovy-archives/groovy-binary-*.zip repository/groovy-$VERSION.zip
cp groovy-archives/version repository/version
