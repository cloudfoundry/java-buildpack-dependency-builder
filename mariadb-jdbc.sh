#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

upload_path() {
  echo "/mariadb-jdbc/mariadb-jdbc-$VERSION.jar"
}

VERSION=$(cat mariadb-jdbc-archives/version)

UPLOAD_PATH=$(upload_path)
INDEX_PATH="/mariadb-jdbc/index.yml"

transfer_to_s3 "mariadb-jdbc-archives/mariadb-jdbc-$VERSION.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
