#!/usr/bin/env bash

set -euo pipefail

VERSION=$(cat postgresql-jdbc-archives/version)

cp postgresql-jdbc-archives/postgresql-*.jar repository/postgresql-jdbc-$VERSION.jar
cp postgresql-jdbc-archives/version repository/version
