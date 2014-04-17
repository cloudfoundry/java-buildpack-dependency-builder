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
require 'build/dependency/mariadb_jdbc'

describe Build::Dependency::MariaDbJDBC do
  include_context 'dependency_helper'

  it 'should create MariaDB JDBC URI' do
    expect_version_uri '1.1.7', 'http://mirrors.coreix.net/mariadb/client-java-1.1.7/mariadb-java-client-1.1.7.jar'
  end

end
