#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tomee-archives/version)

cp tomee-archives/apache-tomee-*-webprofile.tar.gz repository/tomee-$VERSION.tar.gz
cp tomee-archives/version repository/version
