#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat slf4j-jdk14-archives/version)

INDEX_PATH="/slf4j-jdk14/index.yml"
UPLOAD_PATH="/slf4j-jdk14/slf4j-jdk14-$VERSION.jar"

transfer_to_s3 "slf4j-jdk14-archives/slf4j-jdk14-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
