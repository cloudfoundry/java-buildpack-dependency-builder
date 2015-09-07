#!/usr/bin/env bash
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

PACKAGES=" \
	alsa-lib-devel \
	cups-devel \
	freetype-devel \
	libXi-devel \
	libxml2-devel \
	libXrender-devel \
	libxslt-devel \
	libXt-devel \
	libXtst-devel \
	openssl-devel \
	readline-devel \
	unzip \
	zip"

rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
rpm -Uvh http://pkgs.repoforge.org/mercurial/mercurial-2.2.2-1.el6.rfx.x86_64.rpm

yum update -y
yum groupinstall -y "Development Tools" --skip-broken
yum install -y $PACKAGES
