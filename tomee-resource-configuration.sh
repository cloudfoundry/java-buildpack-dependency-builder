#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tomee-resource-configuration-archives/version)

INDEX_PATH="/tomee-resource-configuration/index.yml"
UPLOAD_PATH="/tomee-resource-configuration/tomee-resource-configuration-$VERSION.jar"

transfer_to_s3 "tomee-resource-configuration-archives/tomee-resource-configuration-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
