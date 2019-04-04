#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tomcat-lifecycle-support-archives/version)

cp tomcat-lifecycle-support-archives/tomcat-lifecycle-support-*.jar repository/tomcat-lifecycle-support-$VERSION.jar
cp tomcat-lifecycle-support-archives/version repository/version
