#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat skywalking-archives/version)

INDEX_PATH="/skywalking/index.yml"
UPLOAD_PATH="/skywalking/skywalking-$VERSION.tar.gz"

transfer_to_s3 "skywalking-archives/skywalking-agent.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
