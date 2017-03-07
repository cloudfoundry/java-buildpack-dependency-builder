#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat log4j-core-archives/version)

INDEX_PATH="/log4j-core/index.yml"
UPLOAD_PATH="/log4j-core/log4j-core-$VERSION.jar"

transfer_to_s3 "log4j-core-archives/log4j-core-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
