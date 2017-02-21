#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/play-jpa-plugin/play-jpa-plugin-$VERSION.jar"
}

VERSION=$(cat play-jpa-plugin-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/play-jpa-plugin/index.yml"

transfer_to_s3 "play-jpa-plugin-archives/play-jpa-plugin-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
