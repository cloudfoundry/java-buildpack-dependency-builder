#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat play-jpa-plugin-archives/version)

INDEX_PATH="/play-jpa-plugin/index.yml"
UPLOAD_PATH="/play-jpa-plugin/play-jpa-plugin-$VERSION.jar"

transfer_to_s3 "play-jpa-plugin-archives/play-jpa-plugin-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
