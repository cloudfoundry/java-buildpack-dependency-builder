#!/usr/bin/env bash

set -e -x

source $(dirname "$0")/common.sh

# $1: The Tomcat version
download_uri() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  if [[ "$DOWNLOAD_VERSION" =~ ^6 ]]; then
    echo "http://archive.apache.org/dist/tomcat/tomcat-6/v$DOWNLOAD_VERSION/bin/apache-tomcat-$DOWNLOAD_VERSION.tar.gz"
  elif [[ "$DOWNLOAD_VERSION" =~ ^7 ]]; then
    echo "http://archive.apache.org/dist/tomcat/tomcat-7/v$DOWNLOAD_VERSION/bin/apache-tomcat-$DOWNLOAD_VERSION.tar.gz"
  elif [[ "$DOWNLOAD_VERSION" =~ ^8 ]]; then
    echo "http://archive.apache.org/dist/tomcat/tomcat-8/v$DOWNLOAD_VERSION/bin/apache-tomcat-$DOWNLOAD_VERSION.tar.gz"
  else
    echo "Unable to process version '$DOWNLOAD_VERSION'" >&2
    exit 1
  fi
}

# $1: The Tomcat version
upload_path() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/tomcat/tomcat-$UPLOAD_VERSION.tar.gz"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH=$(upload_path)
INDEX_PATH="/tomcat/index.yml"

transfer_direct $DOWNLOAD_URI $UPLOAD_PATH
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
