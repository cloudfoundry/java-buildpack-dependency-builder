#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/slf4j-jdk14/slf4j-jdk14-$VERSION.jar"
}

VERSION=$(cat slf4j-jdk14-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/slf4j-jdk14/index.yml"

transfer_to_s3 "slf4j-jdk14-archives/slf4j-jdk14-$VERSION.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
