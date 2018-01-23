#!/usr/bin/env bash

set -e -u -o pipefail

source $(dirname "$0")/common.sh

build() {
  if [[ -z "$BUILD_NUMBER" ]]; then
    echo "BUILD_NUMBER must be set" >&2
    exit 1
  fi

  pushd jdk9u
    ./configure \
      --disable-warnings-as-errors \
      --with-cacerts-file=$(pwd)/../cacerts.jks \
      --with-native-debug-symbols=none \
      --with-version-pre= \
      --with-version-opt=\
      --with-version-build=$BUILD_NUMBER \
      $(freetype_flags) \
      $(xcode_location)

    make images

    chmod -R a+r build/$(release_name)/images
    tar czvf $(pwd)/../openjdk-jdk.tar.gz -C build/$(release_name)/images/jdk .
    tar czvf $(pwd)/../openjdk.tar.gz -C build/$(release_name)/images/jre . -C ../jdk ./bin/jcmd ./bin/jimage ./bin/jmap ./bin/jstack ./man/man1/jcmd.1 ./man/man1/jmap.1 ./man/man1/jstack.1 $(libattach_location)
  popd
}

clone_repository() {
  if [[ -z "$TAG" ]]; then
    echo "TAG must be set" >&2
    exit 1
  fi

  hg clone http://hg.openjdk.java.net/jdk-updates/jdk9u

  pushd jdk9u
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
  split_cacerts cacerts.pem cacerts

  for I in $(find cacerts -type f | sort) ; do
    echo "Importing $I"
    keytool -importcert -noprompt -keystore cacerts.jks -storepass changeit -file $I -alias $(basename $I)
  done
}

freetype_flags() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  if [[ "$PLATFORM" == "mountainlion" ]]; then
    echo "--with-freetype-include=/usr/local/include/freetype2 \
      --with-freetype-lib=/usr/local/lib"
  else
    echo "--with-freetype-include=/usr/include/freetype2 \
      --with-freetype-lib=/usr/lib/x86_64-linux-gnu"
  fi
}

libattach_location() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  if [[ "$PLATFORM" == "mountainlion" ]]; then
    echo "./lib/libattach.dylib"
  else
    echo "./lib/libattach.so"
  fi
}

release_name() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  if [[ "$PLATFORM" == "mountainlion" ]]; then
    echo "macosx-x86_64-normal-server-release"
  else
    echo "linux-x86_64-normal-server-release"
  fi
}

split_cacerts() {
  if [[ -z "$PLATFORM" ]]; then
    echo "PLATFORM must be set" >&2
    exit 1
  fi

  local source=$1
  local target=$2

  mkdir -p $target

  if [[ "$PLATFORM" == "mountainlion" ]]; then
    split -a 3 -p '-----BEGIN CERTIFICATE-----' $source $target/
    rm $target/aaa
  else
    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{ print $0; }' $source | csplit -n 3 -s -f $target/ - '/-----BEGIN CERTIFICATE-----/' {*}
    rm $target/000
  fi
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

xcode_location() {
  if [[ -n "$XCODE_LOCATION" ]]; then
    echo "--with-toolchain-path=$XCODE_LOCATION/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
  else
    echo ""
  fi
}

PATH=/usr/local/bin:$PATH

BUILD_NUMBER="$(cat java-archives/build_number)"
TAG="jdk-$(cat java-archives/major_version).$(cat java-archives/minor_version).$(cat java-archives/update_version)+$(cat java-archives/build_number)"
UPLOAD_VERSION="$(cat java-archives/major_version).$(cat java-archives/minor_version).$(cat java-archives/update_version)_$(cat java-archives/build_number)"

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
