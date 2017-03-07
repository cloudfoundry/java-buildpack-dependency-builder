#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

VERSION=$(cat mariadb-jdbc-archives/version)

INDEX_PATH="/mariadb-jdbc/index.yml"
UPLOAD_PATH="/mariadb-jdbc/mariadb-jdbc-$VERSION.jar"

transfer_to_s3 "mariadb-jdbc-archives/mariadb-java-client-*.jar" $UPLOAD_PATH
update_index $INDEX_PATH $VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
