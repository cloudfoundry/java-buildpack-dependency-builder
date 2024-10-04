#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."

export CGO_ENABLED=0

echo "Building AppDynamics"
cp Dockerfile ../../appdynamics-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../appdynamics-builder/check appdynamics/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../appdynamics-builder/in    appdynamics/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../appdynamics-builder/out   appdynamics/cmd/out.go

echo "Building AdoptOpenJDK"
cp Dockerfile ../../adoptopenjdk-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../adoptopenjdk-builder/check adoptopenjdk/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../adoptopenjdk-builder/in    adoptopenjdk/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../adoptopenjdk-builder/out   adoptopenjdk/cmd/out.go

echo "Building Artifactory"
cp Dockerfile ../../artifactory-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../artifactory-builder/check artifactory/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../artifactory-builder/in    artifactory/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../artifactory-builder/out   artifactory/cmd/out.go

echo "Building Bellsoft"
cp Dockerfile ../../bellsoft-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../bellsoft-builder/check bellsoft-liberica/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../bellsoft-builder/in    bellsoft-liberica/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../bellsoft-builder/out   bellsoft-liberica/cmd/out.go

echo "Building Corretto"
cp Dockerfile ../../corretto-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../corretto-builder/check corretto/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../corretto-builder/in    corretto/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../corretto-builder/out   corretto/cmd/out.go

echo "Building GCS Repository"
cp Dockerfile ../../gcs-repository-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../gcs-repository-builder/check gcs-repository/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../gcs-repository-builder/in    gcs-repository/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../gcs-repository-builder/out   gcs-repository/cmd/out.go

echo "Building Gradle"
cp Dockerfile ../../gradle-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../gradle-builder/check gradle/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../gradle-builder/in    gradle/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../gradle-builder/out   gradle/cmd/out.go

echo "Building HTTP"
cp Dockerfile ../../http-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../http-builder/check http/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../http-builder/in    http/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../http-builder/out   http/cmd/out.go

echo "Building JProfiler"
cp Dockerfile ../../jprofiler-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../jprofiler-builder/check jprofiler/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../jprofiler-builder/in    jprofiler/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../jprofiler-builder/out   jprofiler/cmd/out.go

echo "Building Maven"
cp Dockerfile ../../maven-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../maven-builder/check maven/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../maven-builder/in    maven/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../maven-builder/out   maven/cmd/out.go

echo "Building NPM"
cp Dockerfile ../../npm-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../npm-builder/check npm/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../npm-builder/in    npm/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../npm-builder/out   npm/cmd/out.go

echo "Building Repository"
cp Dockerfile ../../repository-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../repository-builder/check repository/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../repository-builder/in    repository/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../repository-builder/out   repository/cmd/out.go

echo "Building Sky Walking"
cp Dockerfile ../../sky-walking-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../sky-walking-builder/check skywalking/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../sky-walking-builder/in    skywalking/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../sky-walking-builder/out   skywalking/cmd/out.go

echo "Building Tomcat"
cp Dockerfile ../../tomcat-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../tomcat-builder/check tomcat/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../tomcat-builder/in    tomcat/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../tomcat-builder/out   tomcat/cmd/out.go

echo "Building WildFly"
cp Dockerfile ../../wildfly-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../wildfly-builder/check wildfly/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../wildfly-builder/in    wildfly/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../wildfly-builder/out   wildfly/cmd/out.go

echo "Building YourKit"
cp Dockerfile ../../your-kit-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../your-kit-builder/check yourkit/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../your-kit-builder/in    yourkit/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../your-kit-builder/out   yourkit/cmd/out.go

echo "Building Zulu"
cp Dockerfile ../../zulu-builder
GOOS="linux" go build -ldflags='-s -w' -o ../../zulu-builder/check zulu/cmd/check.go
GOOS="linux" go build -ldflags='-s -w' -o ../../zulu-builder/in    zulu/cmd/in.go
GOOS="linux" go build -ldflags='-s -w' -o ../../zulu-builder/out   zulu/cmd/out.go

