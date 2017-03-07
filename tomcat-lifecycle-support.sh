#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tomcat-lifecycle-support-archives/version)

INDEX_PATH="/tomcat-lifecycle-support/index.yml"
UPLOAD_PATH="/tomcat-lifecycle-support/tomcat-lifecycle-support-$VERSION.jar"

transfer_to_s3 "tomcat-lifecycle-support-archives/tomcat-lifecycle-support-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
