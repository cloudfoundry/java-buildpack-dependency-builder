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

require 'build/dependency'
require 'build/dependency/base'
require 'build/maven'

module Build
  module Dependency

    class PlayJPAPlugin < Base
      include Build::Maven

      def initialize(options)
        super 'play-jpa-plugin', 'jar', options
      end

      protected

      def version_specific(version)
        if version =~ /BUILD/
          ->(v) { snapshot GO_PIVOTAL_SNAPSHOT, 'org.cloudfoundry', 'play-jpa-plugin', v }
        elsif version =~ /RELEASE/
          ->(v) { release GO_PIVOTAL_RELEASE, 'org.cloudfoundry', 'play-jpa-plugin', v }
        elsif version =~ /[\d]+\.[\d]+\.[\d]+/
          ->(v) { release SPRING_MILESTONE, 'org.cloudfoundry', 'play-jpa-plugin', v }
        else
          fail "Unable to process version '#{version}'"
        end
      end

    end

  end
end
