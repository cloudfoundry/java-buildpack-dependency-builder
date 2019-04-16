#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIRECTORY="java-8-release"
DESTINATION_DIRECTORY="images"

PATTERN="jdk8u([0-9]+)-b([0-9]+)"

build() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    bash get_source.sh

    bash common/bin/hgforest.sh checkout $(tag)

    bash configure \
      --disable-debug-symbols \
      --disable-zip-debug-info \
      --enable-unlimited-crypto \
      --with-build-number=$(build_number) \
      --with-cacerts-file=$(pwd)/$(ls ../cacerts-repository/*.jks) \
      --with-debug-level=release \
      --with-freetype-include=/usr/include/freetype2 \
      --with-freetype-lib=/usr/lib/x86_64-linux-gnu \
      --with-milestone=fcs \
      --with-update-version=$(update_version) \
      --with-vendor-name="Pivotal Software Inc" \
      --with-vendor-url="https://pivotal.io"

    CFLAGS=$(cflags) make images

  popd > /dev/null
}

build_number() {
  for TAG in $(hg log -r "." --template "{latesttag}\n" | tr ":" "\n"); do
    if [[ ${TAG} =~ ${PATTERN} ]]; then
      printf "%02.f" ${BASH_REMATCH[2]:-0}
      return
    fi
  done
}

cflags() {
  if [[ "$(platform)" == "trusty" ]]; then
    echo "-Wno-error=deprecated-declarations -Wno-deprecated-declarations"
  else
    echo "-Wno-deprecated-declarations -Wno-error=deprecated-declarations -Wno-error=format-overflow -Wno-error=nonnull"
  fi
}

package() {
  chmod -R a+r ${SOURCE_DIRECTORY}/build/linux-x86_64-normal-server-release/images

  local identifier="$(version)-$(platform)"

  tar czvf ${DESTINATION_DIRECTORY}/openjdk-jre-${identifier}.tar.gz -C ${SOURCE_DIRECTORY}/build/linux-x86_64-normal-server-release/images/j2re-image .
  tar czvf ${DESTINATION_DIRECTORY}/openjdk-jdk-${identifier}.tar.gz -C ${SOURCE_DIRECTORY}/build/linux-x86_64-normal-server-release/images/j2sdk-image .
  echo $(semver) >> ${DESTINATION_DIRECTORY}/version
}

platform() {
  lsb_release -cs
}

semver() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    for TAG in $(hg log -r "." --template "{latesttag}\n" | tr ":" "\n"); do
      if [[ ${TAG} =~ ${PATTERN} ]]; then
        echo "1.8.0-$(printf "%03d" ${BASH_REMATCH[1]:-0})"
        return
      fi
    done

  popd > /dev/null
}

tag() {
  for TAG in $(hg log -r "." --template "{latesttag}\n" | tr ":" "\n"); do
    if [[ ${TAG} =~ ${PATTERN} ]]; then
      echo ${TAG}
      return
    fi
  done
}

update_version() {
  for TAG in $(hg log -r "." --template "{latesttag}\n" | tr ":" "\n"); do
    if [[ ${TAG} =~ ${PATTERN} ]]; then
      printf "%03d" ${BASH_REMATCH[1]:-0}
      return
    fi
  done
}

version() {
  pushd ${SOURCE_DIRECTORY} > /dev/null

    for TAG in $(hg log -r "." --template "{latesttag}\n" | tr ":" "\n"); do
      if [[ ${TAG} =~ ${PATTERN} ]]; then
        echo "1.8.0_$(printf "%03d" ${BASH_REMATCH[1]:-0})"
        return
      fi
    done

  popd > /dev/null
}

build
package
