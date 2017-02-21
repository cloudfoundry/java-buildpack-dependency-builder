#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/auto-reconfiguration/auto-reconfiguration-$VERSION.jar"
}

VERSION=$(cat auto-reconfiguration-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/auto-reconfiguration/index.yml"

transfer_to_s3 "auto-reconfiguration-archives/auto-reconfiguration-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
