#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/tomcat/tomcat-$VERSION.tar.gz"
}

VERSION=$(cat tomcat-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/tomcat/index.yml"

transfer_to_s3 "tomcat-archives/apache-tomcat-*.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
