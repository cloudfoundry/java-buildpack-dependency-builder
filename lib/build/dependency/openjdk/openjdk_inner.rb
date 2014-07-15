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
require 'build/dependency/openjdk/ant_builder'
require 'build/dependency/openjdk/ca_certs_builder'
require 'build/dependency/openjdk/jdk6_cloner'
require 'build/dependency/openjdk/jdk7_cloner'
require 'build/dependency/openjdk/jdk8_cloner'
require 'build/dependency/openjdk/bootstrap_jdk_builder'
require 'build/dependency/openjdk/jre6_and_7_jre_builder'
require 'build/dependency/openjdk/jre8_jre_builder'
require 'build/dependency/openjdk/openjdk_resources'
require 'build/dependency/util/platform_details'

module Build
  module Dependency

    class OpenJDKInner < Base
      include OpenJDKResources
      include PlatformDetails

      def initialize(options)
        super 'openjdk', 'tar.gz', options
      end

      protected

      def base_path
        "openjdk/#{codename}/#{architecture}"
      end

      def source
        version_details = version_specific @version, @development

        ant_builder = AntBuilder.new
        ant_builder.build

        bootstrap_jdk_builder = BootstrapJDKBuilder.new
        bootstrap_jdk_builder.build

        cacerts_builder = CACertsBuilder.new
        cacerts_builder.build

        cloner = version_details[:cloner]
        cloner.clone
        cloner.checkout_tag @tag
        cloner.apply_patches

        jre_builder = version_details[:jre_builder]
        jre_builder.build(@version, @build_number,
                          ant_builder.root, bootstrap_jdk_builder.root, cacerts_builder.cacerts,
                          cloner.source_location, @jdk)

        jre_builder.package
      end

      private

      def version_specific(version, development)
        if version =~ /^1.6/
          {
            cloner:      JDK6Cloner.new(development),
            jre_builder: JRE6And7JREBuilder.new
          }
        elsif version =~ /^1.7/
          {
            cloner:      JDK7Cloner.new(development),
            jre_builder: JRE6And7JREBuilder.new
          }
        elsif version =~ /^1.8/
          {
            cloner:      JDK8Cloner.new(development),
            jre_builder: JRE8JREBuilder.new
          }
        else
          fail "Unable to process version '#{version}'"
        end
      end

    end

  end
end
