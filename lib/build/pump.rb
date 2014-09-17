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
require 'build'
require 'build/proxy'
require 'mime/types'
require 'net/http'
require 'ruby-progressbar'
require 'tempfile'

module Build

  class Pump
    include Build::Proxy

    def initialize(title, source, destination, source_headers = nil, progress_stream = nil)
      @destination     = destination
      @progress_stream = progress_stream
      @source          = source
      @source_headers  = source_headers
      @title           = title
    end

    def pump
      progress_bar = ProgressBar.create(format: PROGRESS_BAR_FORMAT, title: @title, output: @progress_stream)

      begin
        size               = source_size
        progress_bar.total = block_given? ? (size + 1) : (2 * size) # Index file display problems (1/2)

        Tempfile.open('builder') do |file|
          download file, progress_bar

          if block_given?
            yield file
            progress_bar.total += (file.size - 1) # Index file display problems (2/2)
          end

          upload file, progress_bar
        end
      rescue => e
        progress_bar.log e.message
        raise e
      ensure
        progress_bar.stop
      end
    end

    private

    CHUNK_SIZE = 8192.freeze

    PROGRESS_BAR_FORMAT = '%t |%B| %E'.freeze

    REDIRECT_TYPES = [
      Net::HTTPMovedPermanently,
      Net::HTTPFound,
      Net::HTTPSeeOther,
      Net::HTTPTemporaryRedirect
    ].freeze

    private_constant :CHUNK_SIZE, :PROGRESS_BAR_FORMAT, :REDIRECT_TYPES

    def content_type
      MIME::Types.of(@destination.key).first
    end

    def download(file, progress_bar)
      if @source.is_a? URI
        download_from_uri @source, file, progress_bar
      elsif @source.is_a? AWS::S3::S3Object
        download_from_aws @source, file, progress_bar
      elsif @source.is_a? Tempfile
        download_from_file @source, file, progress_bar
      else
        fail "Unable to download from #{@source}"
      end
    ensure
      file.fsync
      file.close
    end

    def download_from_aws(object, file, progress_bar)
      return unless object.exists?

      object.read do |chunk|
        file.write chunk
        progress_bar.progress += chunk.length
      end
    end

    def download_from_file(source, file, progress_bar)
      File.open(source, 'rb') do |source_file|
        File.open(file, 'wb') do |destination_file|
          until source_file.eof?
            content = source_file.read CHUNK_SIZE
            destination_file.write content
            progress_bar.progress += content.length if content
          end
        end
      end
    end

    def download_from_uri(location, file, progress_bar)
      proxy(location).start(location.host, location.port, use_ssl: secure?(location)) do |http|
        http.request_get(location.request_uri, @source_headers) do |response|
          if response.is_a? Net::HTTPOK
            response.read_body do |chunk|
              file.write chunk
              progress_bar.progress += chunk.length
            end
          elsif redirect?(response)
            download_from_uri URI(response['Location']), file, progress_bar
          else
            fail "Unable to download from '#{location}'.  Received '#{response.code}'."
          end
        end
      end
    end

    def redirect?(response)
      REDIRECT_TYPES.any? { |t| response.is_a? t }
    end

    def source_size
      if @source.is_a? URI
        source_size_from_uri @source
      elsif @source.is_a? AWS::S3::S3Object
        source_size_from_aws @source
      elsif @source.is_a? Tempfile
        @source.size
      else
        0
      end
    end

    def source_size_from_aws(object)
      object.exists? ? object.content_length : 0
    end

    def source_size_from_uri(location)
      size = nil

      proxy(location).start(location.host, location.port, use_ssl: secure?(location)) do |http|
        http.request_head(location.path, @source_headers) do |response|
          if response.is_a? Net::HTTPOK
            size = response['Content-Length'].to_i
          elsif redirect?(response)
            size = source_size_from_uri URI(response['Location'])
          else
            fail "Unable to get size from '#{location}'.  Received '#{response.code}'."
          end
        end
      end

      size
    end

    def upload(file, progress_bar)
      File.open(file, 'rb') do |f|
        @destination.write(content_length: file.size, content_type: content_type) do |buffer, bytes|
          content = f.read bytes
          buffer.write content
          progress_bar.progress += content.length if content
        end
      end
    end
  end

end
