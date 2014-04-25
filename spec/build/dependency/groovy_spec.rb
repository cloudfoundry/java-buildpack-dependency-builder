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
require 'build/dependency/groovy'

describe Build::Dependency::Groovy do
  include_context 'dependency_helper'

  it 'should create groovy post 2.2.1 URI' do
    expect_version_uri '2.2.2', 'http://dl.bintray.com/groovy/maven/groovy-binary-2.2.2.zip'
  end

  it 'should create groovy post 1.4 URI' do
    expect_version_uri '2.1.0', 'http://dist.groovy.codehaus.org/distributions/groovy-binary-2.1.0.zip'
  end

end
