#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat tomcat-archives/version)

cp tomcat-archives/apache-tomcat-*.tar.gz repository/tomcat-$VERSION.tar.gz
cp tomcat-archives/version repository-version
