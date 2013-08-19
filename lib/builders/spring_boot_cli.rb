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

  class SpringBootCLI < Base

    def initialize(options)
      super 'spring-boot-cli', 'tar.gz', options
    end

    def version_specific(version)
      if version =~ /BUILD/
        ->(v) { "http://repo.springsource.org/simple/libs-snapshot-local/org/springframework/boot/spring-boot-cli/#{non_qualifier_version v}.BUILD-SNAPSHOT/spring-boot-cli-#{v}-bin.tar.gz" }
      elsif version =~ /\.M/
        ->(v) { "http://repo.springsource.org/milestone/org/springframework/boot/spring-boot-cli/#{v}/spring-boot-cli-#{v}-bin.tar.gz" }
      else
        fail "Unable to process version '#{version}'"
      end
    end

    protected

    def normalize(raw)
      components = raw.split('.')
      mmm = components[0..2]
      q = components[3, components.length - 3]
      new_q = q && q.length > 0 ? '_' + q.join('.') : nil
      mmm.join('.') + (new_q ? new_q : '')
    end

    private

    def non_qualifier_version(version)
      version.split('.')[0..2].join('.')
    end

  end

end
