#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/log4j-slf4j-impl/log4j-slf4j-impl-$VERSION.jar"
}

VERSION=$(cat log4j-slf4j-impl-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/log4j-slf4j-impl/index.yml"

transfer_to_s3 "log4j-slf4j-impl-archives/log4j-slf4j-impl-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
