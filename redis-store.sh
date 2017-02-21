#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/redis-store/redis-store-$VERSION.jar"
}

VERSION=$(cat redis-store-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/redis-store/index.yml"

transfer_to_s3 "redis-store-archives/redis-store-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
