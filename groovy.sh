#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat groovy-archives/version)

INDEX_PATH="/groovy/index.yml"
UPLOAD_PATH="/groovy/groovy-$VERSION.zip"

transfer_to_s3 "groovy-archives/groovy-binary-*.zip" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
