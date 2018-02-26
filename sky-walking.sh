#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat sky-walking-archives/version)

INDEX_PATH="/sky-walking/index.yml"
UPLOAD_PATH="/sky-walking/sky-walking-$VERSION.tar.gz"

transfer_to_s3 "sky-walking-archives/skywalking-agent.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
