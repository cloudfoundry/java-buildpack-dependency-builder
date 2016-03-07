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
require 'fileutils'
require 'tempfile'

module Build
  module Dependency
    class YourKitInner < Base
      def initialize(options)
        super 'your-kit', nil, options
      end

      protected

      def base_path
        "#{@name}/#{@platform}/x86_64"
      end

      def normalize(raw)
        components = raw.split('.')
        if components[0] == '2016'
          build_part = components[1].split('-b')
          "#{components[0]}.#{build_part[0]}.#{build_part[1]}"
        else
          "#{raw}.0"
        end
      end

      def source
        agent = Tempfile.new('your-kit-agent')

        Tempfile.open('your-kit') do |zip_file|
          uri = URI(instance_exec(@version, &version_specific(@version)))
          system "curl -ssL #{uri} -o #{File.absolute_path zip_file}"

          Dir.mktmpdir do |unzipped|
            system "unzip -qq #{File.absolute_path zip_file} -d #{File.absolute_path unzipped} 2>&1"
            FileUtils.cp agent_lib(unzipped), agent
          end
        end

        agent
      end

      def type_specific(_version)
        @platform == 'mountainlion' ? 'jnilib' : 'so'
      end

      def version_specific(version)
        if version =~ /^[\d]+\.[\w|-]+$/
          lambda do |v|
            components = v.split('.')
            if components[0] == '2016'
              "https://www.yourkit.com/download/yjp-#{components[0]}.#{components[1]}.zip"
            else
              "https://www.yourkit.com/download/yjp-#{components[0]}-build-#{components[1]}.zip"
            end
          end
        else
          fail "Unable to process version '#{version}'"
        end
      end

      private

      def agent_lib(unzipped)
        path = @platform == 'mountainlion' ? 'bin/mac/libyjpagent.jnilib' : 'bin/linux-x86-64/libyjpagent.so'
        Pathname.new(unzipped).children.first + path
      end
    end
  end
end
