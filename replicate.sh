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
  --include "groovy/*" \
  --include "new-relic/*" \
  --include "postgresql-jdbc/*" \
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
  --exclude "*/lucid/*"

find $DESTINATION -name "index.yml" | xargs sed -ie "s|https://download.run.pivotal.io|$BASE_URI|g"
