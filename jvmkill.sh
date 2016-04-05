#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

clone_repository() {
  if [[ -z "$TAG" ]]; then
    echo "TAG must be set" >&2
    exit 1
  fi

  git clone https://github.com/cloudfoundry/jvmkill.git

  pushd jvmkill
    git checkout $TAG
  popd
}

upload_path() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/jvmkill/$PLATFORM/x86_64/jvmkill-$UPLOAD_VERSION.so"
}

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/jvmkill/$PLATFORM/x86_64/index.yml"

clone_repository
jvmkill/ci/build.sh
transfer_to_s3 'jvmkill/libjvmkill.so' $UPLOAD_PATH
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
