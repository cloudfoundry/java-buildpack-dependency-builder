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
require 'build/dependency/base'
require 'build/mmmq_normalizer'

module Build
  module Dependency
    class MemoryCalculatorInner < Base
      include Build::MMMQNormalizer

      def initialize(options)
        super 'memory-calculator', nil, options
      end

      protected

      def base_path
        "#{@name}/#{@platform}/x86_64"
      end

      def version_specific(version)
        if version =~ /RELEASE/ || version =~ /\.M/
          lambda do |v|
            "https://github.com/cloudfoundry/java-buildpack-memory-calculator/releases/download/v#{v}/" \
            "java-buildpack-memory-calculator-#{platform_qualifier}"
          end
        else
          fail "Unable to process version '#{version}'"
        end
      end

      private

      def platform_qualifier
        @platform == 'mountainlion' ? 'darwin' : 'linux'
      end
    end
  end
end
