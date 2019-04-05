#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat jprofiler-archives/version)

cp jprofiler-archives/jprofiler_linux_*.tar.gz repository/jprofiler-$VERSION.tar.gz
cp jprofiler-archives/version repository/version
