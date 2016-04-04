#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

download_uri() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "https://repo1.maven.org/maven2/org/slf4j/slf4j-jdk14/$DOWNLOAD_VERSION/slf4j-jdk14-$DOWNLOAD_VERSION.jar"
}

upload_path() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/slf4j-jdk14/slf4j-jdk14-$UPLOAD_VERSION.jar"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH=$(upload_path)
INDEX_PATH="/slf4j-jdk14/index.yml"

transfer_direct $DOWNLOAD_URI $UPLOAD_PATH
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
