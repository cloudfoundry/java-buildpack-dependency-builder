#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/tomcat-logging-support/tomcat-logging-support-$VERSION.jar"
}

VERSION=$(cat tomcat-logging-support-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/tomcat-logging-support/index.yml"

transfer_to_s3 "tomcat-logging-support-archives/tomcat-logging-support-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
