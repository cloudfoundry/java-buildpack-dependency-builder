#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tomee-archives/version)

INDEX_PATH="/tomee/index.yml"
UPLOAD_PATH="/tomee/tomee-$VERSION.tar.gz"

transfer_to_s3 "tomee-archives/apache-tomee-*-webprofile.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
