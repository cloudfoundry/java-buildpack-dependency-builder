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

require 'spec_helper'
require 'build/dependency/dependency_helper'
require 'build/dependency/log4j_jcl'

describe Build::Dependency::Log4jJcl do
  include_context 'dependency_helper'

  it 'should create Log4j Jcl URI' do
    expect_version_uri '3.5.1', 'http://central.maven.org/maven2/org/apache/logging/log4j/log4j-jcl/3.5.1/log4j-jcl-3.5.1.jar'
  end

end
