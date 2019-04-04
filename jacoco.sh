#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat jacoco-archives/version)

cp jacoco-archives/org.jacoco.agent-*.jar repository/jacoco-$VERSION.jar
cp jacoco-archives/version repository/version
