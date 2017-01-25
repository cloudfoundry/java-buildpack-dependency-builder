#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

download_uri_darwin() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo $(spring_release_uri 'org.cloudfoundry' 'java-buildpack-memory-calculator' $DOWNLOAD_VERSION "-darwin.tar.gz")
}

download_uri_linux() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo $(spring_release_uri 'org.cloudfoundry' 'java-buildpack-memory-calculator' $DOWNLOAD_VERSION "-linux.tar.gz")
}

upload_path_mountainlion() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/memory-calculator/mountainlion/x86_64/memory-calculator-$UPLOAD_VERSION.tar.gz"
}

upload_path_trusty() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/memory-calculator/trusty/x86_64/memory-calculator-$UPLOAD_VERSION.tar.gz"
}

DOWNLOAD_URI_DARWIN=$(download_uri_darwin)
DOWNLOAD_URI_LINUX=$(download_uri_linux)
UPLOAD_PATH_MOUNTAINLION=$(upload_path_mountainlion)
UPLOAD_PATH_TRUSTY=$(upload_path_trusty)
INDEX_PATH_MOUNTAINLION="/memory-calculator/mountainlion/x86_64/index.yml"
INDEX_PATH_TRUSTY="/memory-calculator/trusty/x86_64/index.yml"

transfer_direct $DOWNLOAD_URI_DARWIN $UPLOAD_PATH_MOUNTAINLION
transfer_direct $DOWNLOAD_URI_LINUX $UPLOAD_PATH_TRUSTY
update_index $INDEX_PATH_MOUNTAINLION $UPLOAD_VERSION $UPLOAD_PATH_MOUNTAINLION
update_index $INDEX_PATH_TRUSTY $UPLOAD_VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_MOUNTAINLION $UPLOAD_PATH_MOUNTAINLION $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
