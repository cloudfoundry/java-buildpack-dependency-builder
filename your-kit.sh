#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat your-kit-archives/version)

unzip -qq your-kit-archives/YourKit-JavaProfiler-*.zip

cp YourKit-JavaProfiler-*/bin/linux-x86-64/libyjpagent.so repository/your-kit-${VERSION}.so
cp your-kit-archives/version repository/version
