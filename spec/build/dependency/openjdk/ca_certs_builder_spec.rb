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
require 'build/dependency/openjdk/ca_certs_builder'
require 'English'

describe Build::Dependency::CACertsBuilder do
  include_context 'console_helper'

  let(:builder) { described_class.new }

  let(:cacerts) { File.expand_path('vendor/openjdk/cacerts') }

  it 'should return a cacerts location' do
    expect(builder.cacerts).to eq(cacerts)
  end

  it 'should not build if already exists' do
    expect(File).to receive(:exist?).with(cacerts).and_return(true)
    expect(described_class).not_to receive(:system)

    builder.build
  end

  it 'should create on OS X' do
    expect(File).to receive(:exist?).with(cacerts).and_return(false)
    expect(builder).to receive(:macosx?).and_return(true)
    expect(builder).to receive(:system).with(/split -p/)

    builder.build
  end

  it 'should create on non-OS X' do
    expect(File).to receive(:exist?).with(cacerts).and_return(false)
    expect(builder).to receive(:macosx?).and_return(false)
    expect(builder).to receive(:system).with(/csplit -s -f/)

    builder.build
  end

end
