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
require 'build/dependency/tomcat'

describe Build::Dependency::Tomcat do
  include_context 'dependency_helper'

  it 'should create Tomcat 6 URI' do
    expect_version_uri '6.0.0', 'http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.0/bin/apache-tomcat-6.0.0.tar.gz'
  end

  it 'should create Tomcat 7 URI' do
    expect_version_uri '7.0.0', 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.0/bin/apache-tomcat-7.0.0.tar.gz'
  end

  it 'should create Tomcat 8 URI' do
    expect_version_uri '8.0.0', 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.0/bin/apache-tomcat-8.0.0.tar.gz'
  end

  it 'should return the raw version for normalized' do
    expect(dependency.send(:normalize, '6.0.0')).to eq('6.0.0')
  end

end
