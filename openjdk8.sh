#!/usr/bin/env bash

set -euo pipefail

cp jdk-8/bellsoft-jdk*.tar.gz images
cp jre-8/bellsoft-jre*.tar.gz images

PATTERN="([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)"
if [[ $(cat jdk-8/version) =~ ${PATTERN} ]]; then
  echo "1.${BASH_REMATCH[1]}.${BASH_REMATCH[2]}_${BASH_REMATCH[3]}" > images/version
else
  echo "version is not semver" 1>&2
  exit 1
fi
