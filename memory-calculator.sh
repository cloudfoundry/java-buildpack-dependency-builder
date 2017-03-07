#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat memory-calculator-archives/version)

INDEX_PATH_MOUNTAINLION="/memory-calculator/mountainlion/x86_64/index.yml"
INDEX_PATH_TRUSTY="/memory-calculator/trusty/x86_64/index.yml"
UPLOAD_PATH_MOUNTAINLION="/memory-calculator/mountainlion/x86_64/memory-calculator-$VERSION.tar.gz"
UPLOAD_PATH_TRUSTY="/memory-calculator/trusty/x86_64/memory-calculator-$VERSION.tar.gz"

transfer_to_s3 "memory-calculator-archives/java-buildpack-memory-calculator-*-darwin.tar.gz" $UPLOAD_PATH_MOUNTAINLION
transfer_to_s3 "memory-calculator-archives/java-buildpack-memory-calculator-*-linux.tar.gz" $UPLOAD_PATH_TRUSTY
update_index $INDEX_PATH_MOUNTAINLION $VERSION $UPLOAD_PATH_MOUNTAINLION
update_index $INDEX_PATH_TRUSTY $VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_MOUNTAINLION $UPLOAD_PATH_MOUNTAINLION $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
