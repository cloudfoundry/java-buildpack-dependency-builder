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
require 'build/dependency/util/base_vagrant_platform'
require 'fileutils'

module Build
  module Dependency

    class BaseVagrant

      def initialize(command, vagrant_platform_type, options)
        options.each { |key, value| instance_variable_set("@#{key}", value) }

        @command   = command
        @platforms = options[:platforms].map do |platform|
          vagrant_platform_type.new(platform, @version, @shutdown)
        end
      end

      def build
        FileUtils.rm_f cached_configuration
        FileUtils.cp File.expand_path(@configuration), cached_configuration

        command = ['bundle', 'exec', 'bin/build', @command, "--configuration vendor/#{CONFIGURATION}"]
        command.concat arguments

        @platforms.each do |platform|
          platform.exec command.join(' ')
        end
      end

      protected

      def arguments
        fail "Method 'arguments' must be defined"
      end

      private

      CONFIGURATION = 'java_buildpack_dependency_builder.yml'.freeze

      VENDOR_DIR = File.expand_path('../../../../vendor', __FILE__).freeze

      private_constant :CONFIGURATION

      def cached_configuration
        File.join(VENDOR_DIR, CONFIGURATION)
      end

    end

  end
end
