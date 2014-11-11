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
require 'open-uri'
require 'replicate'
require 'replicate/object'

module Replicate
  class ObjectCollection < Array
    def initialize
      marker = nil

      loop do
        document = document marker
        objects  = objects document

        concat objects.select { |object| object.key !~ /\/$/ && object.key !~ /^assets\// }

        break unless truncated? document
        marker = marker objects
      end
    end

    private

    def document(marker)
      Nokogiri::XML(open(uri(marker)))
    end

    def marker(objects)
      objects.last.key
    end

    def objects(document)
      document.xpath('./xmlns:ListBucketResult/xmlns:Contents').map { |contents| Object.new contents }
    end

    def truncated?(document)
      is_truncated = document.xpath('./xmlns:ListBucketResult/xmlns:IsTruncated').first
      return false unless is_truncated

      is_truncated.content.casecmp('true').zero?
    end

    def uri(marker)
      uri = 'http://download.pivotal.io.s3.amazonaws.com/'
      uri += "?marker=#{marker}" if marker
      uri
    end
  end
end
