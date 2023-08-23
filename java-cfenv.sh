#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat java-cfenv-archives/version)

cp java-cfenv-archives/java-cfenv*.jar repository/java-cfenv-$VERSION.jar
cp java-cfenv-archives/version repository/version
