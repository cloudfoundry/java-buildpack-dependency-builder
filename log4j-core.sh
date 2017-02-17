#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/log4j-core/log4j-core-$VERSION.jar"
}

VERSION=$(cat log4j-core-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/log4j-core/index.yml"

transfer_to_s3 "log4j-core-archives/log4j-core-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
