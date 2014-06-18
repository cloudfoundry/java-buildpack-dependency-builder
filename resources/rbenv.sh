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

VERSION="0.4.0"

mkdir -p "$HOME/.rbenv"
curl -sSL "https://github.com/sstephenson/rbenv/archive/v${VERSION}.tar.gz" | tar xzvf - --strip 1 -C "$HOME/.rbenv"
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bash_profile
echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
. $HOME/.bash_profile

mkdir -p "$HOME/.rbenv/plugins/ruby-build"
curl -sSL "https://github.com/sstephenson/ruby-build/archive/master.tar.gz" | tar xzvf - --strip 1 -C "$HOME/.rbenv/plugins/ruby-build"

cd /java-buildpack-dependency-builder
rbenv install
gem install bundler --no-rdoc --no-ri
rbenv rehash
bundle install
