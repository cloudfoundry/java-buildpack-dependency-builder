#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat tc-server-archives/version)

INDEX_PATH="/tc-server/index.yml"
UPLOAD_PATH="/tc-server/tc-server-$VERSION.tar.gz"

transfer_to_s3 "tc-server-archives/pivotal-tc-server-standard-*.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
