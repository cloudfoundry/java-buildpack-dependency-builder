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

  class TcServer < Base

    def initialize(options)
      super 'tc-server', 'tar.gz', options
    end

    protected

    def normalize(raw)
      components = raw.split('.')
      mmm = components[0..2]
      q = components[3, components.length - 3]
      new_q = q && q.length > 0 ? '_' + q.join('.') : nil
      mmm.join('.') + (new_q ? new_q : '')
    end

    def version_specific(version)
      ->(v) { "http://dist.springsource.com.s3.amazonaws.com/release/TCS/vfabric-tc-server-standard-#{v}.tar.gz" }
    end

  end

end
