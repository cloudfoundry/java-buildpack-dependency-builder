#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat spring-boot-cli-archives/version)

cp spring-boot-cli-archives/spring-boot-cli-*-bin.tar.gz repository/spring-boot-cli-$VERSION.tar.gz
cp spring-boot-cli-archives/version repository/version
