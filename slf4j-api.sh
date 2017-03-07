#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat slf4j-api-archives/version)

INDEX_PATH="/slf4j-api/index.yml"
UPLOAD_PATH="/slf4j-api/slf4j-api-$VERSION.jar"

transfer_to_s3 "slf4j-api-archives/slf4j-api-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
