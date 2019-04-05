#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat memory-calculator-archives/version)

cp memory-calculator-archives/java-buildpack-memory-calculator-*.tar.gz repository/memory-calculator-$VERSION.tar.gz
cp memory-calculator-archives/version repository/version
