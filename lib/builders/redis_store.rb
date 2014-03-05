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

require 'builders/base'
require 'builders/util/mmmq_normalizer'

module Builders
  class RedisStore < Base
    include Builders::MMMQNormalizer

    def initialize(options)
      super 'redis-store', 'jar', options
    end

    protected

    def version_specific(version)
      if version =~ /BUILD/
        ->(v) { "http://maven.gopivotal.com.s3.amazonaws.com/snapshot/com/gopivotal/manager/redis-store/#{non_qualifier_version v}.BUILD-SNAPSHOT/redis-store-#{v}.jar" }
      else
        ->(v) { "http://maven.gopivotal.com.s3.amazonaws.com/release/com/gopivotal/manager/redis-store/#{v}/redis-store-#{v}.jar" }
      end
    end

  end
end
