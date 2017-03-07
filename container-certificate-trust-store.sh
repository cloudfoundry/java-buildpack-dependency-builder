#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat container-certificate-trust-store-archives/version)

INDEX_PATH="/container-certificate-trust-store/index.yml"
UPLOAD_PATH="/container-certificate-trust-store/container-certificate-trust-store-$VERSION.jar"

transfer_to_s3 "container-certificate-trust-store-archives/java-buildpack-container-certificate-trust-store-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
