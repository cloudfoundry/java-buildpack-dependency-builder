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

PACKAGES=" \
	alsa-lib-devel \
	ant \
	ant-nodeps \
	cups-devel \
	freetype-devel \
	java-1.6.0-openjdk \
	libXi-devel \
	libxml2-devel \
	libXrender-devel \
	libxslt-devel \
	libXt-devel \
	libXtst-devel \
	mercurial \
	unzip \
	zip"


yum update -y
yum install -y $PACKAGES

curl -L https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 1.9.3
bundle install --gemfile /java-buildpack-dependency-builder/Gemfile
