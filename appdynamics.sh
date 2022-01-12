#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat appdynamics-archives/version)
EXT=$(cat appdynamics-archives/extension)

cp appdynamics-archives/appdynamics_linux_*.$EXT "repository/appdynamics-$VERSION.$EXT"
cp appdynamics-archives/version repository/version
