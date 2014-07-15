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

VERSION="2.7.6"

curl -sSL "http://boxes.gopivotal.com.s3.amazonaws.com/mountainlion64-XQuartz-${VERSION}.dmg" > "${TMPDIR}/xquartz.dmg"
hdiutil mount "${TMPDIR}/xquartz.dmg"
installer -package "/Volumes/XQuartz-${VERSION}/XQuartz.pkg" -target "/Volumes/Macintosh HD"
hdiutil unmount "/Volumes/XQuartz-${VERSION}"
