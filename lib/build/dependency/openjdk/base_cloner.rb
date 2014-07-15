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

module Build
  module Dependency

    class BaseCloner
      include OpenJDKResources

      attr_reader :source_location

      def initialize(repository, development)
        @repository      = "#{repository.chomp('/')}#{'-dev' if development}"
        @source_location = File.join(VENDOR_DIR, "source/#{repository.split('/').last}")
      end

      def clone
        hgrc = File.join ENV['HOME'], '/.hgrc'
        File.open(hgrc, 'w') { |f| f.write "[extensions]\npurge =\n" } unless File.exist? hgrc

        if File.exist? @source_location
          puts "Updating #{@source_location} from #{@repository}..."
          Dir.chdir(@source_location) do
            system 'chmod +x make/scripts/hgforest.sh'
            system 'make/scripts/hgforest.sh purge --all'
            system 'make/scripts/hgforest.sh update --clean'
            system 'chmod +x make/scripts/hgforest.sh'
          end
        else
          puts "Cloning #{@repository} to #{@source_location}..."

          FileUtils.mkdir_p @source_location
          system "hg clone #{@repository} #{@source_location}"

          Dir.chdir @source_location do
            system 'chmod +x get_source.sh make/scripts/hgforest.sh'
            system './get_source.sh'
          end
        end

        abort unless $CHILD_STATUS == 0
      end

      def checkout_tag(tag)
        puts "Checking out #{tag}..."
        Dir.chdir @source_location do
          system "make/scripts/hgforest.sh checkout --clean #{tag}"
        end

        abort unless $CHILD_STATUS == 0
      end

      def apply_patches
        Dir.chdir(@source_location) { patches.each { |patch| system "patch -N -p0 -i #{patch}" } }
      end

      protected

      def patches
        []
      end

    end

  end
end
