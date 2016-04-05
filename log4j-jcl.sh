#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

download_uri() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo $(maven_central_uri 'org.apache.logging.log4j' 'log4j-jcl' $DOWNLOAD_VERSION)
}

upload_path() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/log4j-jcl/log4j-jcl-$UPLOAD_VERSION.jar"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH=$(upload_path)
INDEX_PATH="/log4j-jcl/index.yml"

transfer_direct $DOWNLOAD_URI $UPLOAD_PATH
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
