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
require 'build/dependency/jboss_as'

describe Build::Dependency::JBossAS do
  include_context 'dependency_helper'

  it 'should create JBoss AS 1.7 URI' do
    expect_version_uri '7.1.1.Final', 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz'
  end

  it 'should return the MMMQ for normalized' do
    expect(dependency.send(:normalize, '7.1.1.Final')).to eq('7.1.1_Final')
  end

end
