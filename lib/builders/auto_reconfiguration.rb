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

module Builders

  class AutoReconfiguration < Base

    def initialize(options)
      super 'auto-reconfiguration', 'jar', options
    end

    def version_specific(version)
      ->(v) { "http://maven.springframework.org.s3.amazonaws.com/milestone/org/cloudfoundry/auto-reconfiguration/#{v}/auto-reconfiguration-#{v}.jar" }
    end

  end

end
