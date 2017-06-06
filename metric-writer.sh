#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat metric-writer-archives/version)

INDEX_PATH="/metric-writer/index.yml"
UPLOAD_PATH="/metric-writer/metric-writer-$VERSION.jar"

transfer_to_s3 "metric-writer-archives/java-buildpack-metric-writer-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
