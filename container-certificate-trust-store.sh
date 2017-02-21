#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/container-certificate-trust-store/container-certificate-trust-store-$VERSION.jar"
}

VERSION=$(cat container-certificate-trust-store-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/container-certificate-trust-store/index.yml"

transfer_to_s3 "container-certificate-trust-store-archives/java-buildpack-container-certificate-trust-store-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
