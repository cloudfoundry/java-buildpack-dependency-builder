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

require 'build'
require 'build/mmmq_normalizer'

module Build
  module Maven
    include Build::MMMQNormalizer

    GEMFIRE_RELEASE = 'http://dist.gemstone.com.s3.amazonaws.com/maven/release'.freeze

    GO_PIVOTAL_RELEASE = 'http://maven.gopivotal.com.s3.amazonaws.com/release'.freeze

    GO_PIVOTAL_SNAPSHOT = 'http://maven.gopivotal.com.s3.amazonaws.com/snapshot'.freeze

    MAVEN_CENTRAL = 'http://central.maven.org/maven2'.freeze

    SPRING_IO_MILESTONE = 'http://repo.spring.io/milestone'.freeze

    SPRING_IO_RELEASE = 'http://repo.spring.io/release'.freeze

    SPRING_IO_SNAPSHOT = 'http://repo.spring.io/snapshot'.freeze

    SPRING_MILESTONE = 'http://maven.springframework.org.s3.amazonaws.com/milestone'.freeze

    def snapshot(repository, group_id, artifact_id, version, extension = '.jar')
      "#{repository}/#{to_path group_id}/#{artifact_id}/#{non_qualifier_version version}.BUILD-SNAPSHOT/#{artifact_id}-#{version}#{extension}"
    end

    def milestone(repository, group_id, artifact_id, version, extension = '.jar')
      "#{repository}/#{to_path group_id}/#{artifact_id}/#{version}/#{artifact_id}-#{version}#{extension}"
    end

    alias_method :release, :milestone

    private

    def to_path(group_id)
      group_id.tr('.', '/')
    end
  end
end
