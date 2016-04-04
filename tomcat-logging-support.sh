#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

download_uri() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "http://repo.spring.io/release/org/cloudfoundry/tomcat-logging-support/$DOWNLOAD_VERSION/tomcat-logging-support-$DOWNLOAD_VERSION.jar"
}

upload_path() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/tomcat-logging-support/tomcat-logging-support-$UPLOAD_VERSION.jar"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH=$(upload_path)
INDEX_PATH="/tomcat-logging-support/index.yml"

transfer_direct $DOWNLOAD_URI $UPLOAD_PATH
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
