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
require 'build/dependency/openjdk/local_platform'
require 'build/dependency/openjdk/vagrant_platform'
require 'build/dependency/openjdk/openjdk_resources'
require 'fileutils'

module Build
  module Dependency

    class OpenJDK
      include OpenJDKResources

      def initialize(options)
        options.each { |key, value| instance_variable_set("@#{key}", value) }

        @platforms = options[:platforms].map do |platform|
          vagrant?(platform) ? VagrantPlatform.new(platform, @version) : LocalPlatform.new
        end
      end

      def build
        FileUtils.rm_f cached_configuration
        FileUtils.cp File.expand_path(@configuration), cached_configuration

        @platforms.each do |platform|
          platform.exec 'bundle exec bin/build openjdk-inner ' \
                          "--configuration vendor/openjdk/#{CONFIGURATION} " \
                          "--version #{@version} " \
                          "--build-number #{@build_number} " \
                          "--tag #{@tag} " \
                          "--development #{@development ? 'true' : 'false'}"
        end
      end

      private

      CONFIGURATION = 'java_buildpack_dependency_builder.yml'.freeze

      VAGRANT_PLATFORMS = %w(centos6 lucid precise trusty).freeze

      private_constant :CONFIGURATION, :VAGRANT_PLATFORMS

      def cached_configuration
        File.join(VENDOR_DIR, CONFIGURATION)
      end

      def vagrant?(platform)
        VAGRANT_PLATFORMS.include? platform
      end

    end

  end
end
