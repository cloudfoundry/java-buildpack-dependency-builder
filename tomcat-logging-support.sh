#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tomcat-logging-support-archives/version)

cp tomcat-logging-support-archives/tomcat-logging-support-*.jar repository/tomcat-logging-support-$VERSION.jar
cp tomcat-logging-support-archives/version repository/version
