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
require 'build/dependency/ruby/ruby_platform_details'

describe Build::Dependency::RubyPlatformDetails do

  let(:stub) { StubRubyPlatformDetails.new }

  it 'should return Homebrew OpenSSL directory on Mac' do
    expect(stub).to receive(:macosx?).and_return(true)
    expect(stub).to receive(:`).with('brew --cellar openssl').and_return('test-cellar')
    expect(stub).to receive(:`).with("brew list --versions openssl | cut -d ' ' -f 2").and_return('test-version')

    expect(stub.openssl_dir).to eq(' --with-openssl-dir=test-cellar/test-version')
  end

  it 'should return empty string on all other platforms' do
    expect(stub).to receive(:macosx?).and_return(false)

    expect(stub.openssl_dir).to be_empty
  end

  class StubRubyPlatformDetails
    include Build::Dependency::RubyPlatformDetails
  end

end
