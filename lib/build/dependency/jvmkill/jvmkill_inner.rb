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
require 'build/dependency/jvmkill/jdk_builder'
require 'build/dependency/jvmkill/jvmkill_resources'
require 'build/dependency/util/platform_details'
require 'tempfile'

module Build
  module Dependency
    class JvmKillInner < Base
      include JvmKillResources
      include PlatformDetails

      def initialize(options)
        super 'jvmkill', nil, options

        @source_location = File.join(VENDOR_DIR, 'source')
      end

      protected

      def base_path
        "#{@name}/#{codename}/#{architecture}"
      end

      def source
        jdk_builder = JDKBuilder.new
        jdk_builder.build

        clone
        checkout_tag @tag
        compile jdk_builder.root
      end

      def type_specific(_version)
        @platform == 'mountainlion' ? 'dylib' : 'so'
      end

      private

      REPOSITORY = 'https://github.com/cloudfoundry/jvmkill.git'.freeze

      private_constant :REPOSITORY

      def clone
        if File.exist? @source_location
          puts "Updating #{@source_location} from #{REPOSITORY}..."
          Dir.chdir(@source_location) do
            system 'git fetch origin'
            system 'git clean -fdx'
            system 'git reset --hard origin/master'
          end
        else
          puts "Cloning #{REPOSITORY} to #{@source_location}..."
          system "git clone #{REPOSITORY} #{@source_location}"
        end

        abort unless $CHILD_STATUS == 0
      end

      def checkout_tag(tag)
        puts "Checking out #{tag}..."
        Dir.chdir @source_location do
          system "git checkout #{tag}"
        end

        abort unless $CHILD_STATUS == 0
      end

      def compile(jdk_root)
        package = Tempfile.new('jvmkill')

        Dir.chdir(@source_location) do
          system <<-EOF
set -e

export JAVA_HOME=#{jdk_root}
make
cp libjvmkill.so #{package.path}
          EOF
        end

        abort unless $CHILD_STATUS == 0
        package
      end
    end
  end
end
