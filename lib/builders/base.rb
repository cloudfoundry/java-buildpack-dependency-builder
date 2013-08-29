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
require 'builders/progress_indicator'
require 'tempfile'

module Builders

  class Base

    def initialize(name, type, options)
      @name = name
      @type = type
      options.each { |key, value| instance_variable_set("@#{key}", value) }

      @s3 = AWS::S3.new(
        access_key_id: @access_key,
        secret_access_key: @secret_access_key
      )
    end

    def publish
      Tempfile.open('builder') do |file|
        download file, @version
        upload file, @bucket, normalize(@version)
        update_index @bucket, normalize(@version)
      end
    end

    protected

    def base_path
      @name
    end

    def download(file, version)
      uri = URI(instance_exec(version, &version_specific(version)))

      print "Downloading #{@name} #{version} from #{uri}"

      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.path)
        http.request request do |response|
          progress = ProgressIndicator.new(response['Content-Length'].to_i)

          response.read_body do |chunk|
            file.write chunk
            progress.increment chunk.length
          end

          progress.finish
        end
      end

      file.close
    end

    def normalize(raw)
      raw
    end

    def version_specific(version)
      fail "Method 'version_specific(version)' must be defined"
    end

    private

    def upload(file, bucket, version)
      print "Uploading #{@name} #{version} to s3://#{bucket}/#{key version}"

      File.open(file, 'rb') do |f|
        progress = ProgressIndicator.new(f.size)

        object = @s3.buckets[bucket].objects[key(version)]
        object.write(content_length: f.size) do |buffer, bytes|
          content = f.read(bytes)
          buffer.write content
          progress.increment content.length if content
        end

        progress.finish
      end
    end

    def update_index(bucket, version)
      print "Adding #{@name} #{version} to index at s3://#{bucket}/#{index_key}"

      index = @s3.buckets[bucket].objects[index_key]
      if index.exists?
        versions = YAML.load(index.read)
      else
        versions = {}
      end

      versions[version] = uri bucket, version
      index.write(versions.to_yaml, content_type: 'text/x-yaml')

      puts ''
    end

    def artifact(version)
      "#{@name}-#{version}.#{@type}"
    end

    def index_key
      "#{base_path}/index.yml"
    end

    def key(version)
      "#{base_path}/#{artifact version}"
    end

    def uri(bucket, version)
      "http://#{bucket}.s3.amazonaws.com/#{key version}"
    end

  end

end
