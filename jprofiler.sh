#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat jprofiler-archives/version)

INDEX_PATH="/jprofiler/index.yml"
UPLOAD_PATH="/jprofiler/jprofiler-$VERSION.tar.gz"

tar xzf jprofiler-archives/jprofiler_linux_*.tar.gz

transfer_to_s3 "jprofiler-archives/jprofiler_linux_*.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
