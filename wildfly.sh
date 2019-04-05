#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat wildfly-archives/version)

cp wildfly-archives/wildfly-*.tar.gz repository/wildfly-$VERSION.tar.gz
cp wildfly-archives/version repository/version
