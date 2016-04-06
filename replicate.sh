#!/usr/bin/env bash

if [[ -z "$BASE_URI" ]]; then
  echo "BASE_URI must be set" >&2
  exit 1
fi

if [[ -z "$DESTINATION" ]]; then
  echo "DESTINATION must be set" >&2
  exit 1
fi

aws s3 sync "s3://download.pivotal.io" "$DESTINATION" --exclude "*" \
  --include "auto-reconfiguration/*" \
  --include "container-customizer/*" \
  --include "gem-fire/*" \
  --include "gem-fire-modules/*" \
  --include "gem-fire-modules-tomcat7/*" \
  --include "gem-fire-security/*" \
  --include "groovy/*" \
  --include "jboss-as/*" \
  --include "jvmkill/*" \
  --include "log4j-api/*" \
  --include "log4j-core/*" \
  --include "log4j-jcl/*" \
  --include "log4j-jul/*" \
  --include "log4j-slf4j-impl/*" \
  --include "mariadb-jdbc/*" \
  --include "memory-calculator/*" \
  --include "new-relic/*" \
  --include "openjdk/*" \
  --include "openjdk-jdk/*" \
  --include "play-jpa-plugin/*" \
  --include "postgresql-jdbc/*" \
  --include "redis-store/*" \
  --include "slf4j-api/*" \
  --include "slf4j-jdk14/*" \
  --include "spring-boot-cli/*" \
  --include "tc-server/*" \
  --include "tomcat/*" \
  --include "tomcat-access-logging-support/*" \
  --include "tomcat-lifecycle-support/*" \
  --include "tomcat-logging-support/*" \
  --include "tomee/*" \
  --include "tomee-resource-configuration/*" \
  --include "your-kit/*" \
  --exclude "*/centos6/*" \
  --exclude "*/lucid/*" \
  --exclude "*/precise/*"

find $DESTINATION -name "index.yml" | xargs sed -ie "s|https://download.run.pivotal.io|$BASE_URI|g"
