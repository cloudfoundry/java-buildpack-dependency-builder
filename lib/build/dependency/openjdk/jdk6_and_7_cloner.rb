# Encoding: utf-8
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

require 'build/dependency'
require 'build/dependency/openjdk/base_cloner'
require 'build/dependency/openjdk/openjdk_resources'

module Build
  module Dependency

    class JDK6And7Cloner < BaseCloner
      include OpenJDKResources

      protected

      def patches
        PATCHES
      end

      PATCHES = [
        File.join(RESOURCES_DIR, '6_and_7/asound.diff'),
        File.join(RESOURCES_DIR, '6_and_7/leaf.diff'),
        File.join(RESOURCES_DIR, '6_and_7/sel.diff'),
        File.join(RESOURCES_DIR, '6_and_7/stat64.diff')
      ].freeze

      private_constant :PATCHES

    end

  end
end
