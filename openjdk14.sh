#!/usr/bin/env bash

set -euo pipefail

cp jdk-14/version images/version
cp jdk-14/bellsoft-jdk*.tar.gz images
cp jre-14/bellsoft-jre*.tar.gz images
