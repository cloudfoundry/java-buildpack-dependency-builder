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
	ant \
	build-essential \
	curl \
	libasound2-dev \
	libcups2-dev \
	libfreetype6-dev \
	libmotif-dev \
	libxml2-dev \
	libxslt-dev \
	libxt-dev \
	libxtst-dev \
	mercurial \
	openjdk-6-jdk \
	ruby \
	ruby-dev \
	zip"

apt-get update
apt-get install -y python-software-properties
add-apt-repository ppa:mercurial-ppa/releases
apt-get update
apt-get install -y $PACKAGES

curl -sL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.1.1
bundle install --gemfile /java-buildpack-dependency-builder/Gemfile
