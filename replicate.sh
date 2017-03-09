#!/usr/bin/env bash

if [[ -z "$BASE_URI" ]]; then
  echo "BASE_URI must be set" >&2
  exit 1
fi

if [[ -z "$DESTINATION" ]]; then
  echo "DESTINATION must be set" >&2
  exit 1
fi

mkdir -p "$DESTINATION"

aws s3 sync "s3://download.pivotal.io" "$DESTINATION" --no-sign-request --exclude "*" \
  --include "auto-reconfiguration/*" \
  --include "container-certificate-trust-store/*" \
  --include "container-customizer/*" \
  --include "groovy/*" \
  --include "jvmkill/*" \
  --include "mariadb-jdbc/*" \
  --include "memory-calculator/*" \
  --include "new-relic/*" \
  --include "openjdk/*" \
  --include "openjdk-jdk/*" \
  --include "play-jpa-plugin/*" \
  --include "postgresql-jdbc/*" \
  --include "redis-store/*" \
  --include "spring-boot-cli/*" \
  --include "tc-server/*" \
  --include "tomcat/*" \
  --include "tomcat-access-logging-support/*" \
  --include "tomcat-lifecycle-support/*" \
  --include "tomcat-logging-support/*" \
  --include "tomee/*" \
  --include "tomee-resource-configuration/*" \
  --include "wildfly/*" \
  --include "your-kit/*" \
  --exclude "*/centos6/*" \
  --exclude "*/lucid/*" \
  --exclude "*/precise/*"

find "$DESTINATION" -name "index.yml" | xargs sed -ie "s|https://java-buildpack.cloudfoundry.org|$BASE_URI|g"
