#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat appdynamics-archives/version)

cp appdynamics-archives/appdynamics_linux_*.tar.gz repository/appdynamics-$VERSION.tar.gz
cp appdynamics-archives/version repository/version
