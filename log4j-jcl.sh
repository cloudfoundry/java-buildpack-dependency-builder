#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat log4j-jcl-archives/version)

INDEX_PATH="/log4j-jcl/index.yml"
UPLOAD_PATH="/log4j-jcl/log4j-jcl-$VERSION.jar"

transfer_to_s3 "log4j-jcl-archives/log4j-jcl-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
