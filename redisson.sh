#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat redisson-archives/version)

cp redisson-all-archives/redisson-all-*.jar repository/redisson-all-$VERSION.jar
cp redisson-tomcat-8-archives/redisson-tomcat-8-*.jar repository/redisson-tomcat-8-$VERSION.jar
cp redisson-tomcat-9-archives/redisson-tomcat-9-*.jar repository/redisson-tomcat-9-$VERSION.jar
cp redisson-tomcat-10-archives/redisson-tomcat-10-*.jar repository/redisson-tomcat-10-$VERSION.jar

tar czf repository/redisson-$VERSION.tgz --strip-components=1 repository/*.jar

cp redisson-all-archives/version repository/version
