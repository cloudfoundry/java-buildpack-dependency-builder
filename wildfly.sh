#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat wildfly-archives/version)

INDEX_PATH="/wildfly/index.yml"
UPLOAD_PATH="/wildfly/wildfly-$VERSION.tar.gz"

transfer_to_s3 "wildfly-archives/wildfly-*.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
