#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat jacoco-archives/version)

INDEX_PATH="/jacoco/index.yml"
UPLOAD_PATH="/jacoco/jacoco-$VERSION.jar"

transfer_to_s3 "jacoco-archives/org.jacoco.agent-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
