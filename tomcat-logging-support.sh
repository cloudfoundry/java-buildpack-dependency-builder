#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tomcat-logging-support-archives/version)

INDEX_PATH="/tomcat-logging-support/index.yml"
UPLOAD_PATH="/tomcat-logging-support/tomcat-logging-support-$VERSION.jar"

transfer_to_s3 "tomcat-logging-support-archives/tomcat-logging-support-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
