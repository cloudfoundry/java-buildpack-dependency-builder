#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat container-customizer-archives/version)

INDEX_PATH="/container-customizer/index.yml"
UPLOAD_PATH="/container-customizer/container-customizer-$VERSION.jar"

transfer_to_s3 "container-customizer-archives/java-buildpack-container-customizer-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
