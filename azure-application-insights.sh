#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat azure-application-insights-archives/version)

cp azure-application-insights-archives/applicationinsights-agent-*.jar repository/azure-application-insights-$VERSION.jar
cp azure-application-insights-archives/version repository/version
