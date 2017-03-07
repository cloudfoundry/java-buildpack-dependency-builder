#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/spring-boot-cli/spring-boot-cli-$VERSION.tar.gz"
}

VERSION=$(cat spring-boot-cli-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/spring-boot-cli/index.yml"

transfer_to_s3 "spring-boot-cli-archives/spring-boot-cli-*-bin.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
