#!/usr/bin/env bash

set -euo pipefail

[[ -d $PWD/maven && ! -d $HOME/.m2 ]] && ln -s $PWD/maven $HOME/.m2

SOURCE_DIRECTORY="product-microgateway"

build() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    sed -i -e 's|<url>http://maven.wso2.org|<url>https://maven.wso2.org|g' pom.xml
    mvn -Dmaven.test.skip=true package

  popd > /dev/null
}

version() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    local version=$(git describe --tags)
    version="${version##v}"

    echo ${version}

  popd > /dev/null
}

VERSION=$(version)

build
cp ${SOURCE_DIRECTORY}/distribution/target/wso2am-micro-gw-${VERSION}.zip repository/wso2am-micro-gw-runtime-${VERSION}.zip
cp ${SOURCE_DIRECTORY}/distribution/target/wso2am-micro-gw-toolkit-${VERSION}.zip repository/wso2am-micro-gw-toolkit-${VERSION}.zip
echo ${VERSION} > repository/version
