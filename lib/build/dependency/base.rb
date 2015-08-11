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

require 'aws-sdk'
require 'build/dependency'
require 'build/invalidator'
require 'build/pump'
require 'pathname'
require 'ruby-progressbar'
require 'yaml'

module Build
  module Dependency
    class Base
      def initialize(name, type, options)
        options.each { |key, value| instance_variable_set("@#{key}", value) }
        @configuration = YAML.load_file File.expand_path(options[:configuration])

        AWS.config(@configuration)

        @bucket             = AWS::S3.new.buckets[@configuration[:bucket]]
        @invalidator        = Invalidator.new(AWS::CloudFront.new, @configuration[:distribution_id])
        @name               = name
        @normalized_version = normalize @version
        @repository_root    = @configuration[:repository_root].chomp('/')
        @type               = type
      end

      def build
        transfer
        update_index
      end

      protected

      def base_path
        @name
      end

      def headers
      end

      def normalize(raw)
        raw
      end

      def source
        URI(instance_exec(@version, &version_specific(@version)))
      end

      def version_specific(_version)
        fail "Method 'version_specific(version)' must be defined"
      end

      def type_specific(_version)
        nil
      end

      private

      def add_version(file)
        versions                      = YAML.load_file(file) || {}
        versions[@normalized_version] = uri @normalized_version
        File.open(file, 'w') { |f| f.write versions.to_yaml }
      end

      def artifact(version)
        artifact = "#{@name}-#{version}"
        @type = type_specific(version) if type_specific(version)
        artifact += ".#{@type}" if @type
        artifact
      end

      def index_key
        "#{base_path}/index.yml"
      end

      def key(version)
        "#{base_path}/#{artifact version}"
      end

      def transfer
        destination = @bucket.objects[key @normalized_version]

        @invalidator.with_invalidation(destination) do
          Pump.new("#{@name} #{@version}", source, destination, headers).pump
        end
      end

      def update_index
        object = @bucket.objects[index_key]

        @invalidator.with_invalidation(object) do
          Pump.new("#{@name} index", object, object).pump { |file| add_version file }
        end
      end

      def uri(version)
        "#{@repository_root}/#{key version}"
      end
    end
  end
end
