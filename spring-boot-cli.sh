#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat spring-boot-cli-archives/version)

INDEX_PATH="/spring-boot-cli/index.yml"
UPLOAD_PATH="/spring-boot-cli/spring-boot-cli-$VERSION.tar.gz"

transfer_to_s3 "spring-boot-cli-archives/spring-boot-cli-*-bin.tar.gz" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
