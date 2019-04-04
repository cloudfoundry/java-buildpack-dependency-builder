#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tomcat-access-logging-support-archives/version)

cp tomcat-access-logging-support-archives/tomcat-access-logging-support-*.jar repository/tomcat-access-logging-support-$VERSION.jar
cp tomcat-access-logging-support-archives/version repository/version
