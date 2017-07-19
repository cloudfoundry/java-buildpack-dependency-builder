#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat client-certificate-mapper-archives/version)

INDEX_PATH="/client-certificate-mapper/index.yml"
UPLOAD_PATH="/client-certificate-mapper/client-certificate-mapper-$VERSION.jar"

transfer_to_s3 "client-certificate-mapper-archives/java-buildpack-client-certificate-mapper-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
