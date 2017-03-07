#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat log4j-api-archives/version)

INDEX_PATH="/log4j-api/index.yml"
UPLOAD_PATH="/log4j-api/log4j-api-$VERSION.jar"

transfer_to_s3 "log4j-api-archives/log4j-api-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
