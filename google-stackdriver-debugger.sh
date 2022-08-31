#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat cloud-debug-java/version)

cp cloud-debug-java/cdbg_java_agent_service_account.tar.gz repository/google-stackdriver-debugger-$VERSION.tar.gz
cp cloud-debug-java/version repository/version
