#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat redisson-archives/version)

cp redisson-all-archives/redisson-all-*.jar repository/redisson-all-$VERSION.jar
cp redisson-tomcat-archives/redisson-tomcat-*.jar repository/redisson-tomcat-$VERSION.jar
cp redisson-archives/version repository/version
