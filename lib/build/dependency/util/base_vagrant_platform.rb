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
require 'English'

module Build
  module Dependency

    class BaseVagrantPlatform

      def self.vagrant?(platform)
        VAGRANT_PLATFORMS.include? platform
      end

      def initialize(name, version)
        @name    = name
        @version = version
      end

      def exec(command)
        Dir.chdir version_specific(@version) do
          system "vagrant up #{@name}"

          system "vagrant ssh #{@name} --command 'cd /java-buildpack-dependency-builder && #{command}'"

          abort 'FAILURE' unless $CHILD_STATUS == 0
          system "vagrant destroy -f #{@name}"
        end
      end

      protected

      def version_specific(_version)
        fail "Method 'version_specific(version)' must be defined"
      end

      VAGRANT_PLATFORMS = %w(centos6 lucid precise trusty).freeze

      private_constant :VAGRANT_PLATFORMS

    end
  end
end
