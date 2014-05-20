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
require 'environment_helper'
require 'build/proxy'
require 'uri'

describe Build::Proxy do
  include_context 'environment_helper'

  let(:stub) { StubProxy.new }

  context do

    let(:environment) { { 'HTTP_PROXY' => 'http://proxy:9000' } }

    it 'should use HTTP_PROXY if specified' do
      expect(Net::HTTP).to receive(:Proxy).with('proxy', 9000, nil, nil).and_call_original

      stub.proxy(URI('http://test/uri'))
    end

  end

  context do

    let(:environment) { { 'http_proxy' => 'http://proxy:9000' } }

    it 'should use http_proxy if specified' do
      expect(Net::HTTP).to receive(:Proxy).with('proxy', 9000, nil, nil).and_call_original

      stub.proxy(URI('http://test/uri'))
    end

  end

  context do

    let(:environment) { { 'HTTPS_PROXY' => 'http://proxy:9000' } }

    it 'should use HTTPS_PROXY if specified' do
      expect(Net::HTTP).to receive(:Proxy).with('proxy', 9000, nil, nil).and_call_original

      stub.proxy(URI('https://test/uri'))
    end

  end

  context do

    let(:environment) { { 'https_proxy' => 'http://proxy:9000' } }

    it 'should use https_proxy if specified' do
      expect(Net::HTTP).to receive(:Proxy).with('proxy', 9000, nil, nil).and_call_original

      stub.proxy(URI('https://test/uri'))
    end

  end

  class StubProxy
    include Build::Proxy
  end

end
