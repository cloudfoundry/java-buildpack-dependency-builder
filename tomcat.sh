#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tomcat-archives/version)

INDEX_PATH="/tomcat/index.yml"
UPLOAD_PATH="/tomcat/tomcat-$VERSION.tar.gz"

transfer_to_s3 "tomcat-archives/apache-tomcat-*.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
