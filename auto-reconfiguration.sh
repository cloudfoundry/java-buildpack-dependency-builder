#!/usr/bin/env bash

set -euo pipefail

source $(dirname "$0")/common.sh

VERSION=$(semver_to_repository_version $(cat auto-reconfiguration-archives/version))

cp auto-reconfiguration-archives/java-buildpack-auto-reconfiguration-*.jar repository/auto-reconfiguration-$VERSION.jar
cp auto-reconfiguration-archives/version repository/version
