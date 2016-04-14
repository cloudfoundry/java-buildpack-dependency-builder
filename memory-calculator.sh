#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

clone_repository() {
  if [[ -z "$TAG" ]]; then
    echo "TAG must be set" >&2
    exit 1
  fi

  git clone https://github.com/cloudfoundry/java-buildpack-memory-calculator.git gopath/src/github.com/cloudfoundry/java-buildpack-memory-calculator

  pushd gopath/src/github.com/cloudfoundry/java-buildpack-memory-calculator
    git checkout $TAG
  popd
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

UPLOAD_PATH_MOUNTAINLION=$(upload_path_mountainlion)
UPLOAD_PATH_TRUSTY=$(upload_path_trusty)
INDEX_PATH_MOUNTAINLION="/memory-calculator/mountainlion/x86_64/index.yml"
INDEX_PATH_TRUSTY="/memory-calculator/trusty/x86_64/index.yml"

clone_repository
gopath/src/github.com/cloudfoundry/java-buildpack-memory-calculator/ci/build.sh
transfer_to_s3 'gopath/src/github.com/cloudfoundry/java-buildpack-memory-calculator/java-buildpack-memory-calculator-darwin.tar.gz' $UPLOAD_PATH_MOUNTAINLION
transfer_to_s3 'gopath/src/github.com/cloudfoundry/java-buildpack-memory-calculator/java-buildpack-memory-calculator-linux.tar.gz' $UPLOAD_PATH_TRUSTY
update_index $INDEX_PATH_MOUNTAINLION $UPLOAD_VERSION $UPLOAD_PATH_MOUNTAINLION
update_index $INDEX_PATH_TRUSTY $UPLOAD_VERSION $UPLOAD_PATH_TRUSTY
invalidate_cache $INDEX_PATH_MOUNTAINLION $UPLOAD_PATH_MOUNTAINLION $INDEX_PATH_TRUSTY $UPLOAD_PATH_TRUSTY
