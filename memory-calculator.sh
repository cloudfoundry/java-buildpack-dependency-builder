#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat memory-calculator-archives/version)

cp memory-calculator-archives/java-buildpack-memory-calculator-*.tgz repository/memory-calculator-$VERSION.tgz
cp memory-calculator-archives/version repository/version
