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
require 'build/dependency/tc_server'

describe Build::Dependency::TcServer do
  include_context 'dependency_helper'

  it 'should create tc Server CI URI' do
    expect_version_uri '2.9.5.CI-123', 'http://dist.springsource.com.s3.amazonaws.com/snapshot/TCS/vfabric-tc-server-standard-2.9.5.CI-123.tar.gz'
  end

  it 'should create tc Server RELEASE URI' do
    expect_version_uri '2.9.5.RELEASE', 'http://dist.springsource.com.s3.amazonaws.com/release/TCS/vfabric-tc-server-standard-2.9.5.RELEASE.tar.gz'
  end

  it 'should create tc Server SR URI' do
    expect_version_uri '2.9.5.SR1', 'http://dist.springsource.com.s3.amazonaws.com/release/TCS/vfabric-tc-server-standard-2.9.5.SR1.tar.gz'
  end

  it 'should return the MMMQ for normalized' do
    expect(dependency.send(:normalize, '2.9.5.RELEASE')).to eq('2.9.5_RELEASE')
  end

end
