#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

PATH=/usr/local/bin:$PATH

cd cloud-profiler-java
make all
tar zcf profiler_java_agent.tar.gz \
    -C .out \
    NOTICES profiler_java_agent.so

VERSION=$(git describe --tags)
VERSION="${VERSION##v}"

INDEX_PATH_BIONIC="/google-stackdriver-profiler/bionic/x86_64/index.yml"
INDEX_PATH_TRUSTY="/google-stackdriver-profiler/trusty/x86_64/index.yml"
UPLOAD_PATH_BIONIC="/google-stackdriver-profiler/bionic/x86_64/google-stackdriver-profiler-$VERSION.tar.gz"
UPLOAD_PATH_TRUSTY="/google-stackdriver-profiler/trusty/x86_64/google-stackdriver-profiler-$VERSION.tar.gz"

transfer_to_s3 "profiler_java_agent.tar.gz" $UPLOAD_PATH_BIONIC
transfer_to_s3 "profiler_java_agent.tar.gz" $UPLOAD_PATH_TRUSTY
update_index $INDEX_PATH $VERSION $UPLOAD_PATH_BIONIC
update_index $INDEX_PATH $VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_BIONIC $UPLOAD_PATH_BIONIC $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
