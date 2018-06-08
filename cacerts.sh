#!/usr/bin/env bash

set -e -u -o pipefail

VERSION=$(cat cacerts-archives/version)

mkdir split

awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{ print $0; }' cacerts-archives/cacert*.pem | csplit -n 3 -s -f split/ - '/-----BEGIN CERTIFICATE-----/' {*}
rm split/000

for I in $(find split -type f | sort) ; do
  echo "Importing $I"
  keytool -importcert -noprompt -keystore cacerts-keystores/cacerts-$VERSION.jks -storepass changeit -file $I -alias $(basename $I)
done
