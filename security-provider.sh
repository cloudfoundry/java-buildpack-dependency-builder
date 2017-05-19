#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat security-provider-archives/version)

INDEX_PATH="/security-provider/index.yml"
UPLOAD_PATH="/security-provider/security-provider-$VERSION.jar"

transfer_to_s3 "security-provider-archives/java-buildpack-security-provider-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
