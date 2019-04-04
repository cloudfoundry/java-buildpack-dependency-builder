#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIRECTORY="cloud-debug-java"

build() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    PATH=/usr/local/bin:$PATH

    bash build.sh

  popd > /dev/null
}

version() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    local version=$(git describe --tags)
    version="${version##v}.0"

    echo ${version}

  popd > /dev/null
}

VERSION=$(version)

build
cp ${SOURCE_DIRECTORY}/cdbg_java_agent_service_account.tar.gz repository/google-stackdriver-debugger-$VERSION.tar.gz
echo ${VERSION} > repository/version
