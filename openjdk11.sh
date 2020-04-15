#!/usr/bin/env bash

set -euo pipefail

cp jdk-11/version images/version
cp jdk-11/bellsoft-jdk*.tar.gz images
cp jre-11/bellsoft-jre*.tar.gz images
