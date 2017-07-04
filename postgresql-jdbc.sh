#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat postgresql-jdbc-archives/version)

INDEX_PATH="/postgresql-jdbc/index.yml"
UPLOAD_PATH="/postgresql-jdbc/postgresql-jdbc-$VERSION.jar"

transfer_to_s3 "postgresql-jdbc-archives/postgresql-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
