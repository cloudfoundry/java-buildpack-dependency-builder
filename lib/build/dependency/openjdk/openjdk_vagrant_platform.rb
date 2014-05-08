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
require 'build/dependency/openjdk/openjdk_resources'
require 'build/dependency/util/base_vagrant_platform'

module Build
  module Dependency

    class OpenJDKVagrantPlatform
      include OpenJDKResources

      protected

      def version_specific(version)
        if version =~ /^1.6/ || version =~ /^1.7/
          File.join(RESOURCES_DIR, '6_and_7')
        elsif version =~ /^1.8/
          File.join(RESOURCES_DIR, '8')
        else
          fail "Unable to process version '#{version}'"
        end
      end

    end
  end
end
