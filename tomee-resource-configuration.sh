#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tomee-resource-configuration-archives/version)

cp tomee-resource-configuration-archives/tomee-resource-configuration-*.jar repository/tomee-resource-configuration-$VERSION.jar
cp tomee-resource-configuration-archives/version repository/version
