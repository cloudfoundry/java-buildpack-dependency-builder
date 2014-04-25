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

    class JRE6And7JREBuilder
      include PlatformDetails

      attr_reader :package

      def initialize
        @package = Tempfile.new('jre')
      end

      def build(version, build_number, _bootstrap_jdk_root, cacerts, source_location)
        puts "Building #{@name} #{version}..."
        Dir.chdir source_location do
          system <<-EOF
unset JAVA_HOME
export LANG=C ALT_BOOTDIR=#{alt_bootdir} ALT_CACERTS_FILE=#{cacerts} PATH=/usr/bin:$PATH
make MILESTONE=fcs JDK_VERSION=#{version} BUILD_NUMBER=#{build_number} ALLOW_DOWNLOADS=true NO_DOCS=true PARALLEL_COMPILE_JOBS=#{cpu_count} HOTSPOT_BUILD_JOBS=#{cpu_count}

tar czvf #{@package.path} --exclude=*.debuginfo --exclude=*.diz -C build/#{build_dir}/j2re-image .
          EOF
        end

        abort unless $CHILD_STATUS == 0
      end

      private

      def build_dir
        macosx? ? 'macosx-x86_64' : 'linux-amd64'
      end

    end

  end
end
