#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat new-relic-archives/version)

INDEX_PATH="/new-relic/index.yml"
UPLOAD_PATH="/new-relic/new-relic-$VERSION.jar"

transfer_to_s3 "new-relic-archives/newrelic-agent-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
