#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

PATH=/usr/local/bin:$PATH

cd cloud-profiler-java
chmod +x build.sh
./build.sh

VERSION=$(git describe --tags)
VERSION="${VERSION##v}.0"

INDEX_PATH="/google-stackdriver-profiler/$PLATFORM/x86_64/index.yml"
UPLOAD_PATH="/google-stackdriver-profiler/$PLATFORM/x86_64/google-stackdriver-profiler-$VERSION.tar.gz"

transfer_to_s3 "cdpf_java_agent_service_account.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
