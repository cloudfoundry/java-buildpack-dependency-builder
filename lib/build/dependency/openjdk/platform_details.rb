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

module Build
  module Dependency
    module PlatformDetails

      def alt_bootdir
        if centos?
          '/usr/lib/jvm/java-1.6.0-openjdk.x86_64'
        elsif macosx?
          ENV['JAVA6_HOME']
        elsif ubuntu?
          '/usr/lib/jvm/java-6-openjdk'
        else
          fail 'Unable to determine ALT_BOOTDIR'
        end
      end

      def architecture
        `uname -m`.strip
      end

      def codename
        if centos?
          File.open('/etc/redhat-release', 'r') { |f| "centos#{f.read.match(/CentOS release (\d)/)[1]}" }
        elsif macosx?
          'mountainlion'
        elsif ubuntu?
          `lsb_release -cs`.strip
        else
          fail 'Unable to determine codename'
        end
      end

      def cpu_count
        if centos?
          `nproc`.strip
        elsif macosx? || ubuntu?
          `sysctl -n hw.ncpu`.strip
        else
          fail 'Unable to determine cpu count'
        end
      end

      def centos?
        File.exist? '/etc/redhat-release'
      end

      def macosx?
        `uname -s` =~ /Darwin/
      end

      def ubuntu?
        !`which lsb_release 2> /dev/null`.empty?
      end

    end
  end
end
