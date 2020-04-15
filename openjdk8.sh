#!/usr/bin/env bash

set -euo pipefail

cp jdk-8/version images/version
cp jdk-8/bellsoft-jdk*.tar.gz images
cp jre-8/bellsoft-jre*.tar.gz images
