#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat container-security-provider-archives/version)

INDEX_PATH="/container-security-provider/index.yml"
UPLOAD_PATH="/container-security-provider/container-security-provider-$VERSION.jar"

transfer_to_s3 "container-security-provider-archives/java-buildpack-container-security-provider-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
