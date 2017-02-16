#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/new-relic/new-relic-$VERSION.jar"
}

VERSION=$(cat new-relic-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/new-relic/index.yml"

transfer_to_s3 "new-relic-archives/newrelic-agent-$VERSION.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
