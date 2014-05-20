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
require 'build/dependency/openjdk/openjdk_resources'
require 'build/dependency/util/platform_details'
require 'fileutils'

module Build
  module Dependency

    class BootstrapJDKBuilder
      include OpenJDKResources
      include PlatformDetails

      def build
        return if File.exist?(root) || macosx?

        puts 'Downloading bootstrap JDK...'
        FileUtils.mkdir_p root
        system "curl -Ls --header 'Cookie: oraclelicense=accept-securebackup-cookie' #{BOOSTRAP_JDK_URI} | tar xz --strip 1 -C #{root}"
      end

      def root
        BOOSTRAP_JDK_ROOT
      end

      BOOSTRAP_JDK_ROOT = File.join VENDOR_DIR, 'bootstrap-jdk'

      BOOSTRAP_JDK_URI = 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz'

      private_constant :BOOSTRAP_JDK_ROOT, :BOOSTRAP_JDK_URI

    end

  end
end
