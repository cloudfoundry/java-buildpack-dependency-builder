#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/log4j-jul/log4j-jul-$VERSION.jar"
}

VERSION=$(cat log4j-jul-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/log4j-jul/index.yml"

transfer_to_s3 "log4j-jul-archives/log4j-jul-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
