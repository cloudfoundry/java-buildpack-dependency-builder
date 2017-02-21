#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/container-customizer/container-customizer-$VERSION.jar"
}

VERSION=$(cat container-customizer-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/container-customizer/index.yml"

transfer_to_s3 "container-customizer-archives/java-buildpack-container-customizer-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
