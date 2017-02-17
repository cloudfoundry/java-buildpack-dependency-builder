#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/postgresql-jdbc/postgresql-jdbc-$VERSION.jar"
}

VERSION=$(cat postgresql-jdbc-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/postgresql-jdbc/index.yml"

transfer_to_s3 "postgresql-jdbc-archives/postgresql-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
