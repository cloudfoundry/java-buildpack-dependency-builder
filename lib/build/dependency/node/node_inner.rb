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
require 'build/dependency/node/node_resources'
require 'build/dependency/util/platform_details'
require 'tempfile'

module Build
  module Dependency

    class NodeInner < Base
      include NodeResources
      include PlatformDetails

      def initialize(options)
        super 'node', 'tar.gz', options

        @source_location = File.join(VENDOR_DIR, 'source')
      end

      protected

      def base_path
        "node/#{codename}/#{architecture}"
      end

      def source
        clone
        checkout_tag @tag
        compile
      end

      private

      REPOSITORY = 'https://github.com/joyent/node.git'.freeze

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

      def compile
        package = Tempfile.new('node')

        Dir.mktmpdir('node-staging') do |staging_dir|
          Dir.chdir(@source_location) do
            system <<-EOF
./configure --prefix #{staging_dir}
make -j #{cpu_count}
make install

tar czvf #{package.path} -C #{staging_dir} .
            EOF
          end
        end

        abort unless $CHILD_STATUS == 0
        package
      end

    end

  end
end
