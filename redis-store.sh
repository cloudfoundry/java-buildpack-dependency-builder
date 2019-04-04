#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat redis-store-archives/version)

cp redis-store-archives/redis-store-*.jar repository/redis-store-$VERSION.jar
cp redis-store-archives/version repository/version
