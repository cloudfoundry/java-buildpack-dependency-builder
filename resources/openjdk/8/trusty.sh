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
	build-essential \
	curl \
	libasound2-dev \
	libcups2-dev \
	libfreetype6-dev \
	libmotif-dev \
	libssl-dev \
	libxml2-dev \
	libxrender-dev \
	libxslt-dev \
	libxt-dev \
	libxtst-dev \
	mercurial \
	ruby \
	ruby-dev \
	zip"

apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:mercurial-ppa/releases
apt-get update
apt-get install -y $PACKAGES
