#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat auto-reconfiguration-archives/version)

INDEX_PATH="/auto-reconfiguration/index.yml"
UPLOAD_PATH="/auto-reconfiguration/auto-reconfiguration-$VERSION.jar"

transfer_to_s3 "auto-reconfiguration-archives/java-buildpack-auto-reconfiguration-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
