#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat auto-reconfiguration-archives/version)

cp auto-reconfiguration-archives/java-buildpack-auto-reconfiguration-*.jar repository/auto-reconfiguration-$VERSION.jar
cp auto-reconfiguration-archives/version repository/version
