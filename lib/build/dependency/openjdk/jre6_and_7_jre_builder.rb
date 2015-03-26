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

      def build(version, build_number, ant_home, bootstrap_jdk_root, cacerts, source_location, package_jdk)
        puts "Building #{@name} #{version}..."
        Dir.chdir source_location do
          system <<-EOF
set -e
export LANG=C PATH=#{bootstrap_jdk_root}/bin:$PATH ANT_HOME=#{ant_home}
export ALT_BOOTDIR=#{bootstrap_jdk_root} ALT_CACERTS_FILE=#{cacerts} ALT_JDK_IMPORT_PATH=#{bootstrap_jdk_root}
make MILESTONE=fcs JDK_VERSION=#{version} BUILD_NUMBER=#{build_number} ALLOW_DOWNLOADS=true NO_DOCS=true PARALLEL_COMPILE_JOBS=#{cpu_count} HOTSPOT_BUILD_JOBS=#{cpu_count}

tar czvf #{@package.path} --exclude=*.debuginfo --exclude=*.diz -C build/#{build_dir}/#{package_dir package_jdk} . -C ../j2sdk-image ./lib/tools.jar ./bin/jcmd ./bin/jmap ./bin/jstack ./man/man1/jcmd.1 ./man/man1/jmap.1 ./man/man1/jstack.1 -C ./jre ./lib/amd64/libattach.so 
          EOF
        end

        abort unless $CHILD_STATUS == 0
      end

      private

      def build_dir
        macosx? ? 'macosx-x86_64' : 'linux-amd64'
      end

      def package_dir(package_jdk)
        package_jdk ? 'j2sdk-image' : 'j2re-image'
      end
    end
  end
end
