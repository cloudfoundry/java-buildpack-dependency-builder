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

require 'replicate'
require 'thor/error'

module Replicate

  class IndexUpdater

    def initialize(base_uri, host_name)
      if base_uri && host_name
        fail Thor::MalformattedArgumentError,
             "Only value can be provided for one of required options '--base-uri', '--host-name'"
      elsif base_uri
        @base_uri = base_uri
      elsif host_name
        @base_uri = "http://#{host_name}"
      else
        fail Thor::MalformattedArgumentError,
             "No value provided for one of required options '--base-uri', '--host-name'"
      end
    end

    def update(replicated_file)
      return unless candidate?(replicated_file)

      content = replicated_file.content.gsub(/#{BASE_URI}/, @base_uri)
      replicated_file.content { |f| f.write content }
    end

    private

    BASE_URI = 'https://download.run.pivotal.io'.freeze

    INDEX_FILE = 'index.yml'.freeze

    private_constant :BASE_URI, :INDEX_FILE

    def candidate?(replicated_file)
      replicated_file.path.basename.to_s == INDEX_FILE
    end

  end

end
