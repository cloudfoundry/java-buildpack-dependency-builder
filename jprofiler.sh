#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat jprofiler-archives/version)

unzip -qq jprofiler-archives/jprofiler-archives/jprofiler_linux_*.tar.gz

cp jprofiler*/bin/linux-x64/libjprofilerti.so repository/jprofiler-${VERSION}.so
cp jprofiler-archives/version repository/version
