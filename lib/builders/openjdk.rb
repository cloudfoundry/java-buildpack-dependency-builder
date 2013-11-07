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

require 'English'

module Builders

  class OpenJDK

    def initialize(options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }

      @platforms = []
      @platforms << VagrantPlatform.new('centos6', @version) if options[:platforms].include? 'centos6'
      @platforms << VagrantPlatform.new('lucid', @version) if options[:platforms].include? 'lucid'
      @platforms << VagrantPlatform.new('precise', @version) if options[:platforms].include? 'precise'
      @platforms << LocalPlatform.new(@version) if options[:platforms].include? 'osx'
    end

    def publish
      @platforms.each do |platform|
        platform.exec "bundle exec bin/build openjdk-inner --access-key #{@access_key} --secret-access-key #{@secret_access_key} --bucket #{@bucket} --version #{@version} --build-number #{@build_number} --tag #{@tag}"
      end
    end

    private

    ROOT_DIR = File.expand_path('../../..', __FILE__)

    VAGRANT_DIR = File.expand_path('../openjdk', __FILE__)

    VERSION_SPECIFIC = {
        six_and_seven: File.join(VAGRANT_DIR, '6_and_7'),
        eight: File.join(VAGRANT_DIR, '8')
    }

    def with_vagrant(platform, &block)
      Dir.chdir version_specific(@version) do
        system "vagrant up #{platform}"

        yield

        abort 'FAILURE' unless $CHILD_STATUS == 0
        system "vagrant destroy -f #{platform}"
      end
    end

    class VagrantPlatform

      def initialize(name, version)
        @name = name
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

      private

      def version_specific(version)
        if version =~ /^1.6/ || version =~ /^1.7/
          VERSION_SPECIFIC[:six_and_seven]
        elsif version =~ /^1.8/
          VERSION_SPECIFIC[:eight]
        else
          fail "Unable to process version '#{version}'"
        end
      end

    end

    class LocalPlatform

      def initialize(version)
        @version = version
      end

      def exec(command)
        Dir.chdir ROOT_DIR do
          system command
        end
      end

    end

  end

end
