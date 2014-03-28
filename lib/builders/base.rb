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
require 'net/http'
require 'securerandom'
require 'tempfile'

module Builders

  class Base

    def initialize(name, type, options)
      @name = name
      @type = type
      options.each { |key, value| instance_variable_set("@#{key}", value) }

      AWS.config(
        access_key_id:     @access_key,
        secret_access_key: @secret_access_key
      )

      @cloudfront = AWS::CloudFront.new
      @s3         = AWS::S3.new
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
      http_download file, uri
    end

    def http_download(file, uri)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.path)

        http.request request do |response|
          status_code = response.code

          if status_code =~ /30[\d]/
            http_download file, URI(response['Location'])
          elsif status_code =~ /200/
            pump file, response
          else
            fail "Unable to download from '#{uri}'.  Received '#{status_code}'."
          end
        end

      end
    end

    def pump(file, response)
      progress = ProgressIndicator.new(response['Content-Length'].to_i)

      response.read_body do |chunk|
        file.write chunk
        progress.increment chunk.length
      end

      progress.finish
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
      object = @s3.buckets[bucket].objects[key(version)]

      with_invalidation(object) do
        print "Uploading #{@name} #{version} to s3://#{bucket}/#{key version}"

        File.open(file, 'rb') do |f|
          progress = ProgressIndicator.new(f.size)

          object.write(content_length: f.size) do |buffer, bytes|
            content = f.read(bytes)
            buffer.write content
            progress.increment content.length if content
          end

          progress.finish
        end
      end
    end

    def update_index(bucket, version)
      index = @s3.buckets[bucket].objects[index_key]

      with_invalidation(index) do
        print "Adding #{@name} #{version} to index at s3://#{bucket}/#{index_key}"

        if index.exists?
          versions = YAML.load(index.read)
        else
          versions = {}
        end

        versions[version] = uri version
        index.write(versions.to_yaml, content_type: 'text/x-yaml')

        puts ''
      end
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

    def uri(version)
      "http://download.run.pivotal.io/#{key version}"
    end

    def with_invalidation(object, &block)
      exist_previously = object.exists?

      yield

      if exist_previously && @distribution_id
        print "Invalidating cache for s3://#{object.bucket.name}/#{object.key}"

        @cloudfront.client.create_invalidation(distribution_id:    @distribution_id,
                                               invalidation_batch: {
                                                 paths:            {
                                                   quantity: 1,
                                                   items:    ["/#{object.key}"]
                                                 },
                                                 caller_reference: SecureRandom.uuid })
        puts ''
      end
    end

  end

end
