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
require 'build/dependency/openjdk/platform_details'
require 'English'
require 'tempfile'

module Build
  module Dependency

    class JRE8JREBuilder
      include PlatformDetails

      attr_reader :package

      def initialize
        @package = Tempfile.new('jre')
      end

      def build(version, build_number, bootstrap_jdk_root, cacerts, source_location)
        puts "Building #{@name} #{version}..."
        Dir.chdir source_location do
          system <<-EOF
export LANG=C PATH=#{bootstrap_jdk_root}/bin:$PATH
bash ./configure --with-cacerts-file=#{cacerts}
make MILESTONE= JDK_VERSION=#{version} JDK_BUILD_NUMBER=#{build_number} ALLOW_DOWNLOADS=true GENERATE_DOCS=false PARALLEL_COMPILE_JOBS=#{cpu_count} HOTSPOT_BUILD_JOBS=#{cpu_count} all

tar czvf #{@package.path} --exclude=*.debuginfo --exclude=*.diz -C build/#{build_dir}/images/j2re-image .
          EOF
        end

        abort unless $CHILD_STATUS == 0
      end

      private

      def build_dir
        macosx? ? 'macosx-x86_64-normal-server-release' : 'linux-x86_64-normal-server-release'
      end

    end

  end
end
