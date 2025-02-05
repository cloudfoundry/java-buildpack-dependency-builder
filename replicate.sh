#!/usr/bin/env bash

set -e -u

if [[ -z "$BASE_URI" ]]; then
  echo "BASE_URI must be set" >&2
  exit 1
fi

if [[ -z "$DESTINATION" ]]; then
  echo "DESTINATION must be set" >&2
  exit 1
fi

mkdir -p "$DESTINATION"

aws s3 sync "s3://java-buildpack.cloudfoundry.org" "$DESTINATION" --no-sign-request --exclude "*" \
  --include "auto-reconfiguration/*" \
  --include "client-certificate-mapper/*" \
  --include "container-customizer/*" \
  --include "container-security-provider/*" \
  --include "contrast-security/*" \
  --include "google-stackdriver-debugger/*" \
  --include "groovy/*" \
  --include "jvmkill/*" \
  --include "mariadb-jdbc/*" \
  --include "memory-calculator/*" \
  --include "metric-writer/*" \
  --include "openjdk/*" \
  --include "postgresql-jdbc/*" \
  --include "redis-store/*" \
  --include "spring-boot-cli/*" \
  --include "tomcat/*" \
  --include "tomcat-access-logging-support/*" \
  --include "tomcat-lifecycle-support/*" \
  --include "tomcat-logging-support/*" \
  --include "tomee/*" \
  --include "tomee-resource-configuration/*" \
  --include "wildfly/*" \
  --exclude "*/centos6/*" \
  --exclude "*/lucid/*" \
  --exclude "*/mountainlion/*" \
  --exclude "*/precise/*"

find "$DESTINATION" -name "index.yml" | xargs sed -ie "s|https://java-buildpack.cloudfoundry.org|$BASE_URI|g"
