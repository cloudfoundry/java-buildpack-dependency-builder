#!/usr/bin/env bash

set -e

source $(dirname "$0")/common.sh

build() {
  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "BUILD_NUMBER must be set" >&2
    exit 1
  fi

  if [[ -z "$UPDATE_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  unset JAVA_HOME

  pushd jdk8u
    ./configure \
      --disable-debug-symbols \
      --disable-zip-debug-info \
      --with-build-number=$BUILD_NUMBER \
      --with-cacerts-file=$(pwd)/../cacerts.jks \
      --with-freetype-include=/usr/include/freetype2 \
      --with-freetype-lib=/usr/lib/x86_64-linux-gnu \
      --with-milestone=fcs \
      --with-update-version=$UPDATE_VERSION

    COMPANY_NAME="Cloud Foundry" make images

    tar czvf $(pwd)/../openjdk-jdk.tar.gz -C build/linux-x86_64-normal-server-release/images/j2sdk-image .
    tar czvf $(pwd)/../openjdk.tar.gz -C build/linux-x86_64-normal-server-release/images/j2re-image . -C ../j2sdk-image ./lib/tools.jar ./bin/jcmd ./bin/jmap ./bin/jstack ./man/man1/jcmd.1 ./man/man1/jmap.1 ./man/man1/jstack.1 -C ./jre ./lib/amd64/libattach.so
  popd
}

clone_repository() {
  if [[ -z "$TAG" ]]; then
    echo "TAG must be set" >&2
    exit 1
  fi

  hg clone http://hg.openjdk.java.net/jdk8u/jdk8u

  pushd jdk8u
    chmod +x \
      common/bin/hgforest.sh \
      configure \
      get_source.sh

    ./get_source.sh
    ./common/bin/hgforest.sh checkout $TAG
  popd
}

create_cacerts() {
  curl -L https://curl.haxx.se/ca/cacert.pem  > cacerts.pem
  local size=$(grep -c -- '-----BEGIN CERTIFICATE-----' cacerts.pem)

  mkdir cacerts
  awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{ print $0; }' cacerts.pem | csplit -n 3 -s -f cacerts/ - '/-----BEGIN CERTIFICATE-----/' {$((size - 1))}

  for I in $(find cacerts -type f | sort) ; do
    if [[ -s $I ]]; then
      echo "Importing $I"
      keytool -importcert -noprompt -keystore cacerts.jks -storepass changeit -file $I -alias $(basename $I)
    fi

  done
}

upload_path_jdk() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/openjdk-jdk/$PLATFORM/x86_64/openjdk-$UPLOAD_VERSION.tar.gz"
}

upload_path_jre() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  if [[ -z "$UPLOAD_VERSION" ]]; then
    echo "UPLOAD_VERSION must be set" >&2
    exit 1
  fi

  echo "/openjdk/$PLATFORM/x86_64/openjdk-$UPLOAD_VERSION.tar.gz"
}

UPLOAD_PATH_JDK=$(upload_path_jdk)
UPLOAD_PATH_JRE=$(upload_path_jre)
INDEX_PATH_JDK="/openjdk-jdk/$PLATFORM/x86_64/index.yml"
INDEX_PATH_JRE="/openjdk/$PLATFORM/x86_64/index.yml"

create_cacerts
clone_repository
build

transfer_to_s3 'openjdk-jdk.tar.gz' $UPLOAD_PATH_JDK
transfer_to_s3 'openjdk.tar.gz' $UPLOAD_PATH_JRE
update_index $INDEX_PATH_JDK $UPLOAD_VERSION $UPLOAD_PATH_JDK
update_index $INDEX_PATH_JRE $UPLOAD_VERSION $UPLOAD_PATH_JRE
invalidate_cache $INDEX_PATH_JDK $INDEX_PATH_JRE $UPLOAD_PATH_JDK $UPLOAD_PATH_JRE
