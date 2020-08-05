#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat contrast-security-archives/version)

cp contrast-security-archives/contrast-agent-*.jar repository/contrast-agent-$VERSION.jar
cp contrast-security-archives/version repository/version
