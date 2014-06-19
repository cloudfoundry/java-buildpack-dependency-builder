#!/usr/bin/env bash
# Copyright (c) 2014 the original author or authors.
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
	git \
	openssl \
	subversion"

echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
sudo xcode-select -switch /usr/bin

brew update
brew install -y $PACKAGES
