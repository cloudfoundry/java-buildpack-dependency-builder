#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tomcat-access-logging-support-archives/version)

INDEX_PATH="/tomcat-access-logging-support/index.yml"
UPLOAD_PATH="/tomcat-access-logging-support/tomcat-access-logging-support-$VERSION.jar"

transfer_to_s3 "tomcat-access-logging-support-archives/tomcat-access-logging-support-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
