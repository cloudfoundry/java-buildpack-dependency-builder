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
require 'build/dependency/util/platform_details'

module Build
  module Dependency
    module RubyPlatformDetails
      include Build::Dependency::PlatformDetails

      def openssl_dir
        if macosx?
          cellar, version = nil

          Bundler.with_clean_env do
            cellar  = `brew --cellar openssl`.chomp
            version = `brew list --versions openssl | cut -d ' ' -f 2`.chomp
          end

          " --with-openssl-dir=#{cellar}/#{version}"
        else
          ''
        end
      end
    end
  end
end
