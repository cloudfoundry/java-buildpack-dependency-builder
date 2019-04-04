#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat new-relic-archives/version)

cp new-relic-archives/newrelic-agent-*.jar repository/new-relic-$VERSION.jar
cp new-relic-archives/version repository/version
