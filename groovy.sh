#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/groovy/groovy-$VERSION.zip"
}

VERSION=$(cat groovy-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/groovy/index.yml"

transfer_to_s3 "groovy-archives/groovy-binary-*.zip" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
