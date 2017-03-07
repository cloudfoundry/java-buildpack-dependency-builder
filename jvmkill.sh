#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat jvmkill-archives/version)

INDEX_PATH_MOUNTAINLION="/jvmkill/mountainlion/x86_64/index.yml"
INDEX_PATH_TRUSTY="/jvmkill/trusty/x86_64/index.yml"
UPLOAD_PATH_MOUNTAINLION="/jvmkill/mountainlion/x86_64/jvmkill-$VERSION.so"
UPLOAD_PATH_TRUSTY="/jvmkill/trusty/x86_64/jvmkill-$VERSION.so"

transfer_to_s3 "jvmkill-archives/jvmkill-*-darwin.so" $UPLOAD_PATH_MOUNTAINLION
transfer_to_s3 "jvmkill-archives/jvmkill-*-trusty.so" $UPLOAD_PATH_TRUSTY
update_index $INDEX_PATH_MOUNTAINLION $VERSION $UPLOAD_PATH_MOUNTAINLION
update_index $INDEX_PATH_TRUSTY $VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_MOUNTAINLION $UPLOAD_PATH_MOUNTAINLION $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
