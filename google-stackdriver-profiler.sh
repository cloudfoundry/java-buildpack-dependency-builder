#!/usr/bin/env bash

set -euo pipefail

VERSION=$(find ./cloud-profiler-java -name "cloud-profiler-java-agent_*.tar.gz" -print0 | sed -z 's/.*cloud-profiler-java-agent_\(.*\).tar.gz/\1/')
cp cloud-profiler-java/cloud-profiler-java-agent_*.tar.gz repository/google-stackdriver-profiler-$VERSION.tar.gz
cp cloud-profiler-java/version repository/version
