#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

download_uri() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "https://www.yourkit.com/download/yjp-$DOWNLOAD_VERSION.zip"
}

upload_path_mountainlion() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/your-kit/mountainlion/x86_64/your-kit-$UPLOAD_VERSION.jnilib"
}

upload_path_trusty() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/your-kit/trusty/x86_64/your-kit-$UPLOAD_VERSION.so"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH_MOUNTAINLION=$(upload_path_mountainlion)
UPLOAD_PATH_TRUSTY=$(upload_path_trusty)
INDEX_PATH_MOUNTAINLION="/your-kit/mountainlion/x86_64/index.yml"
INDEX_PATH_TRUSTY="/your-kit/trusty/x86_64/index.yml"

transfer_to_file $DOWNLOAD_URI 'yjp-linux.zip'
unzip -qq 'yjp-linux.zip'

transfer_to_s3 'yjp-*/bin/mac/libyjpagent.jnilib' $UPLOAD_PATH_MOUNTAINLION
transfer_to_s3 'yjp-*/bin/linux-x86-64/libyjpagent.so' $UPLOAD_PATH_TRUSTY
update_index $INDEX_PATH_MOUNTAINLION $UPLOAD_VERSION $UPLOAD_PATH_MOUNTAINLION
update_index $INDEX_PATH_TRUSTY $UPLOAD_VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_MOUNTAINLION $UPLOAD_PATH_MOUNTAINLION $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
