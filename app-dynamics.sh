#!/usr/bin/env bash

set -e -o pipefail

source $(dirname "$0")/common.sh

download_uri() {
  if [[ -z "$DOWNLOAD_VERSION" ]]; then
    echo "DOWNLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "https://aperture.appdynamics.com/download/prox/download-file/sun-jvm/$DOWNLOAD_VERSION/AppServerAgent-$DOWNLOAD_VERSION.zip"
}

login() {
  if [[ -z "$APP_DYNAMICS_USERNAME" ]]; then
    echo "APP_DYNAMICS_USERNAME must be set" >&2
    exit 1
  fi

  if [[ -z "$APP_DYNAMICS_PASSWORD" ]]; then
    echo "APP_DYNAMICS_PASSWORD must be set" >&2
    exit 1
  fi

  curl --cookie-jar $(cookies_file) --location --fail -X POST -F username=$APP_DYNAMICS_USERNAME -F password=$APP_DYNAMICS_PASSWORD https://login.appdynamics.com/sso/login/ > /dev/null
}

upload_path() {
  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/app-dynamics/app-dynamics-$UPLOAD_VERSION.zip"
}

DOWNLOAD_URI=$(download_uri)
UPLOAD_PATH=$(upload_path)
INDEX_PATH="/app-dynamics/index.yml"


login
transfer_direct $DOWNLOAD_URI $UPLOAD_PATH
update_index $INDEX_PATH $UPLOAD_VERSION $UPLOAD_PATH
invalidate_cache $INDEX_PATH $UPLOAD_PATH
