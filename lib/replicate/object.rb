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

require 'nokogiri'
require 'time'
require 'uri'

module Replicate

  class Object

    attr_reader :content_length, :key, :last_modified

    def initialize(contents)
      @content_length = contents.at_xpath('./xmlns:Size').content.to_i
      @key            = contents.at_xpath('./xmlns:Key').content
      @last_modified  = Time.parse(contents.at_xpath('./xmlns:LastModified').content)
    end

    def read(location = URI("http://download.run.pivotal.io/#{@key}"), &block)
      Net::HTTP.start(location.host, location.port) do |http|
        request = Net::HTTP::Get.new(location.path)

        http.request request do |response|
          status_code = response.code

          if status_code =~ /30[\d]/
            read(URI(response['Location']), &block)
          elsif status_code =~ /200/
            response.read_body(&block)
          else
            fail "Unable to download from '#{uri}'.  Received '#{status_code}'."
          end
        end

      end
    end

  end

end
