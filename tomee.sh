#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/tomee/tomee-$VERSION.tar.gz"
}

VERSION=$(cat tomee-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/tomee/index.yml"

transfer_to_s3 "tomee-archives/apache-tomee-*-webprofile.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
