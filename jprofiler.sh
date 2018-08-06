#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat jprofiler-archives/version)

INDEX_PATH_BIONIC="/jprofiler/bionic/x86_64/index.yml"
INDEX_PATH_TRUSTY="/jprofiler/trusty/x86_64/index.yml"
UPLOAD_PATH_BIONIC="/jprofiler/bionic/x86_64/jprofiler-$VERSION.so"
UPLOAD_PATH_TRUSTY="/jprofiler/trusty/x86_64/jprofiler-$VERSION.so"

tar xzf "jprofiler-archives/jprofiler_linux_*.tar.gz"

transfer_to_s3 'jprofiler*/bin/linux-x64/libjprofilerti.so' $UPLOAD_PATH_TRUSTY
transfer_to_s3 'jprofiler*/bin/linux-x64/libjprofilerti.so' $UPLOAD_PATH_BIONIC
update_index $INDEX_PATH_BIONIC $VERSION $UPLOAD_PATH_BIONIC
update_index $INDEX_PATH_TRUSTY $VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_BIONIC $UPLOAD_PATH_BIONIC $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
