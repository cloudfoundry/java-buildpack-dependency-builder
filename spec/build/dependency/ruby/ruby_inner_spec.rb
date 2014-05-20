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
require 'build/dependency/ruby/ruby_inner'
require 'console_helper'

describe Build::Dependency::RubyInner do
  include_context 'console_helper'

  let(:options) { { configuration: 'spec/fixture/test_configuration.yml', version: 'test-version' } }

  let(:dependency) { described_class.new(options) }

  let(:source_location) { File.expand_path('vendor/ruby/source') }

  before { `pwd` }

  it 'should create codename and architecture qualified base_path' do
    expect(dependency).to receive(:codename).and_return('test-codename')
    expect(dependency).to receive(:architecture).and_return('test-architecture')

    expect(dependency.send(:base_path)).to eq('ruby/test-codename/test-architecture')
  end

  it 'should normalize ruby versions' do
    expect(dependency.send(:normalize, '1.9.3-p547')).to eq('1.9.3_p547')
    expect(dependency.send(:normalize, '2.1.2')).to eq('2.1.2')
  end

  it 'should clone if the repository does not exist' do
    expect(File).to receive(:exist?).with(source_location).and_return false
    expect(Dir).to receive(:chdir).with(source_location).and_call_original
    expect(dependency).to receive(:system).with("git clone https://github.com/sstephenson/ruby-build.git #{source_location}")
    expect(dependency).to receive(:openssl_dir).and_return('test-openssl-dir')
    expect(dependency).to receive(:system).with(/bin\/ruby-build/)

    expect(dependency.send(:source)).to be
  end

  it 'should update the repository if it does exist' do
    expect(File).to receive(:exist?).with(source_location).and_return true
    expect(Dir).to receive(:chdir).with(source_location).twice.times.and_call_original
    expect(dependency).to receive(:system).with('git fetch origin')
    expect(dependency).to receive(:system).with('git clean -fdx')
    expect(dependency).to receive(:system).with('git reset --hard origin/master')
    expect(dependency).to receive(:openssl_dir).and_return('test-openssl-dir')
    expect(dependency).to receive(:system).with(/bin\/ruby-build/)

    expect(dependency.send(:source)).to be
  end

end
