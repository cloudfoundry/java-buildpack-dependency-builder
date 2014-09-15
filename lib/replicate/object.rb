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

require 'net/http'
require 'nokogiri'
require 'replicate'
require 'time'
require 'uri'

module Replicate

  class Object

    attr_reader :key

    def initialize(contents)
      @content_length = contents.at_xpath('./xmlns:Size').content.to_i
      @etag           = contents.at_xpath('./xmlns:ETag').content
      @key            = contents.at_xpath('./xmlns:Key').content
      @last_modified  = Time.parse(contents.at_xpath('./xmlns:LastModified').content)
    end

    def replicate(replicated_file)
      with_object_timing { download URI("https://download.run.pivotal.io/#{@key}"), replicated_file }
    end

    private

    REDIRECT_TYPES = [
      Net::HTTPMovedPermanently,
      Net::HTTPFound,
      Net::HTTPSeeOther,
      Net::HTTPTemporaryRedirect
    ].freeze

    private_constant :REDIRECT_TYPES

    def download(location, replicated_file)
      downloaded = false

      proxy.start(location.host, location.port, :use_ssl => true) do |http|
        http.request(request(location, replicated_file)) do |response|
          if response.is_a? Net::HTTPOK
            write replicated_file, response
            downloaded = true
          elsif response.is_a? Net::HTTPNotModified
            downloaded = false
          elsif redirect?(response)
            downloaded = download URI(response['Location']), replicated_file
          else
            fail "Unable to download from '#{location}'.  Received '#{response.code}'."
          end
        end
      end

      downloaded
    end

    def proxy
      proxy_uri = URI.parse(ENV['https_proxy'] || ENV['HTTPS_PROXY'] || '')
      Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
    end

    def redirect?(response)
      REDIRECT_TYPES.any? { |t| response.is_a? t }
    end

    def request(location, replicated_file)
      request                      = Net::HTTP::Get.new(location.path)
      request['If-None-Match']     = replicated_file.etag if replicated_file.etag?
      request['If-Modified-Since'] = replicated_file.last_modified if replicated_file.last_modified?
      request
    end

    def with_object_timing
      download_start_time = Time.now
      downloaded          = yield
      timing              = downloaded ? (Time.now - download_start_time).duration : 'up to date'
      print "#{@key} (#{@content_length.ibi} => #{timing})\n"
    end

    def write(replicated_file, response)
      replicated_file.content { |f| response.read_body { |chunk| f.write chunk } }
      replicated_file.etag          = @etag
      replicated_file.last_modified = @last_modified
    end

  end

end
