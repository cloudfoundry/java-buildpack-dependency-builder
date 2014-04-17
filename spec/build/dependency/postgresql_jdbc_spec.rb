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
require 'build/dependency/postgresql_jdbc'

describe Build::Dependency::PostgreSQLJDBC do
  include_context 'dependency_helper'

  it 'should create PostgreSQL 9.3 URI' do
    expect_version_uri '9.3-1101', 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1101-jdbc4/postgresql-9.3-1101-jdbc4.jar'
  end

  it 'should create PostgreSQL 9.1 URI' do
    expect_version_uri '9.1-901-1', 'http://central.maven.org/maven2/postgresql/postgresql/9.1-901-1.jdbc4/postgresql-9.1-901-1.jdbc4.jar'
  end

  it 'should create PostgreSQL 9.0 URI' do
    expect_version_uri '9.0-801', 'http://central.maven.org/maven2/postgresql/postgresql/9.0-801.jdbc4/postgresql-9.0-801.jdbc4.jar'
  end

  it 'should create PostgreSQL 8.4 URI' do
    expect_version_uri '8.4-702', 'http://central.maven.org/maven2/postgresql/postgresql/8.4-702.jdbc4/postgresql-8.4-702.jdbc4.jar'
  end

  it 'should return the MMMQ for normalized' do
    expect(dependency.send(:normalize, '9.1-901-1')).to eq('9.1.901_1')
  end

end
