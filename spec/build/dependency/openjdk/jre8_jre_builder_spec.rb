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
require 'console_helper'
require 'build/dependency/openjdk/jre8_jre_builder'
require 'English'

describe Build::Dependency::JRE8JREBuilder do
  include_context 'console_helper'

  let(:builder) { described_class.new }

  before { `pwd` }

  it 'should return a package location' do
    expect(builder.package).to be
  end

  it 'should create on OS X' do
    expect(Dir).to receive(:chdir).with('test-source-location').and_yield
    allow(builder).to receive(:cpu_count).and_return('test-cpu-count')
    allow(builder).to receive(:macosx?).and_return(true)
    allow(builder).to receive(:trusty?).and_return(false)
    expect(builder).to receive(:system) do |arg|
      expect(arg).to match(/macosx-x86_64-normal-server-release/)
      expect(arg).to match(%r{--with-freetype-include=/usr/local/include/freetype2 --with-freetype-lib=/usr/local/lib})
    end

    builder.build 'test-version', 'test-build-number', 'test-ant-home', 'test-bootstrap-jdk-root', 'test-cacerts',
                  'test-source-location', false
  end

  it 'should create on trusty' do
    expect(Dir).to receive(:chdir).with('test-source-location').and_yield
    allow(builder).to receive(:cpu_count).and_return('test-cpu-count')
    allow(builder).to receive(:macosx?).and_return(false)
    allow(builder).to receive(:trusty?).and_return(true)
    expect(builder).to receive(:system) do |arg|
      expect(arg).to match(/linux-x86_64-normal-server-release/)
      expect(arg).to match(%r{--with-freetype-include=/usr/include/freetype2 --with-freetype-lib=/usr/lib/x86_64-linux-gnu})
    end

    builder.build 'test-version', 'test-build-number', 'test-ant-home', 'test-bootstrap-jdk-root', 'test-cacerts',
                  'test-source-location', false
  end

  it 'should create on non-OS X' do
    expect(Dir).to receive(:chdir).with('test-source-location').and_yield
    allow(builder).to receive(:cpu_count).and_return('test-cpu-count')
    allow(builder).to receive(:macosx?).and_return(false)
    allow(builder).to receive(:trusty?).and_return(false)
    expect(builder).to receive(:system).with(/linux-x86_64-normal-server-release/)

    builder.build 'test-version', 'test-build-number', 'test-ant-home', 'test-bootstrap-jdk-root', 'test-cacerts',
                  'test-source-location', false
  end

end
