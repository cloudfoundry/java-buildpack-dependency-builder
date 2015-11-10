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
require 'build/dependency/jvmkill/jvmkill_vagrant_platform'
require 'build/dependency/base_vagrant'

module Build
  module Dependency
    class JvmKill < BaseVagrant
      def initialize(options)
        super 'jvmkill-inner', JvmKillVagrantPlatform, options
      end

      protected

      def arguments
        [
          "--version #{@version}",
          "--tag #{@tag}"
        ]
      end
    end
  end
end
