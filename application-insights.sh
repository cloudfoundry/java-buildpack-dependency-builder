#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat application-insights-archives/version)

INDEX_PATH="/application-insights/index.yml"
UPLOAD_PATH="/application-insights/application-insights-$VERSION.jar"

transfer_to_s3 "application-insights-archives/applicationinsights-agent-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
