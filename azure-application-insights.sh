#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat azure-application-insights-archives/version)

INDEX_PATH="/azure-application-insights/index.yml"
UPLOAD_PATH="/azure-application-insights/azure-application-insights-$VERSION.jar"

transfer_to_s3 "azure-application-insights-archives/applicationinsights-agent-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
