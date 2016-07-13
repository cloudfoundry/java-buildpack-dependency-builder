#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

download_uri() {
  if [[ -z "$RELEASE_ID" ]]; then
    echo "RELEASE_ID must be set" >&2
    exit 1
  fi

  if [[ -z "$PRODUCT_ID" ]]; then
    echo "PRODUCT_ID must be set" >&2
    exit 1
  fi

  echo "https://network.pivotal.io/api/v2/products/pivotal-tcserver/releases/$RELEASE_ID/product_files/$PRODUCT_ID/download"
}

accept_eula() {
if [[ -z "$PIVOTAL_NETWORK_API_KEY" ]]; then
  echo "PIVOTAL_NETWORK_API_KEY must be set" >&2
  exit 1
fi

  if [[ -z "$RELEASE_ID" ]]; then
    echo "RELEASE_ID must be set" >&2
    exit 1
  fi

  curl --cookie $(cookies_file) --data '' --header "Authorization: Token $PIVOTAL_NETWORK_API_KEY" --location --fail https://network.pivotal.io/api/v2/products/pivotal-tcserver/releases/${RELEASE_ID}/eula_acceptance > /dev/null
}

upload_path() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/tc-server/tc-server-$UPLOAD_VERSION.tar.gz"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH=$(upload_path)
INDEX_PATH="/tc-server/index.yml"

accept_eula
transfer_from_pivnet_direct $DOWNLOAD_URI $UPLOAD_PATH $PIVOTAL_NETWORK_API_KEY
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
