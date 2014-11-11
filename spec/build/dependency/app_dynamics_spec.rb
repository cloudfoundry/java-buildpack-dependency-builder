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
require 'build/dependency/app_dynamics'
require 'build/pump'

describe Build::Dependency::AppDynamics do
  include_context 'dependency_helper'

  let(:destination) { double('destination', exists?: false) }

  let(:pump) { double('pump') }

  it 'should create AppDynamics URI' do
    expect_version_uri '3.8.0.1', 'https://download.appdynamics.com/onpremise/public/archives/3.8.0.1/AppServerAgent-3.8.0.1.zip'
  end

  it 'should return the MMMQ for normalized' do
    expect(dependency.send(:normalize, '3.8.0.1')).to eq('3.8.0_1')
  end

  it 'should return SSO cookie in header' do
    stub_request(:post, 'https://login.appdynamics.com/sso/login/')
      .with(body: { 'password' => 'test-password', 'username' => 'test-username' })
      .to_return(status: 200, headers: { 'Set-Cookie' => 'sso-sessionid=test-sso-sessionid' })

    expect(dependency.send(:headers)).to eq('Cookie' => 'sso-sessionid=test-sso-sessionid')
  end

end
