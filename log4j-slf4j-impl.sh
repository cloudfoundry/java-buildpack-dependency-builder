#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat log4j-slf4j-impl-archives/version)

INDEX_PATH="/log4j-slf4j-impl/index.yml"
UPLOAD_PATH="/log4j-slf4j-impl/log4j-slf4j-impl-$VERSION.jar"

transfer_to_s3 "log4j-slf4j-impl-archives/log4j-slf4j-impl-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
