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
      concat contents.map { |contents| Object.new contents }.select { |object| object.key !~ /\/$/ }
    end

    private

    def contents
      Nokogiri::XML(open('http://download.pivotal.io.s3.amazonaws.com/'))
      .xpath('./xmlns:ListBucketResult/xmlns:Contents')
    end

  end

end
