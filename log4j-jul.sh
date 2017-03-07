#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat log4j-jul-archives/version)

INDEX_PATH="/log4j-jul/index.yml"
UPLOAD_PATH="/log4j-jul/log4j-jul-$VERSION.jar"

transfer_to_s3 "log4j-jul-archives/log4j-jul-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
