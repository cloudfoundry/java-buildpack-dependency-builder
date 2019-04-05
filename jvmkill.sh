#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat jvmkill-archives/version)

cp jvmkill-archives/jvmkill-*.so repository/jvmkill-$VERSION.so
cp jvmkill-archives/version repository/version
