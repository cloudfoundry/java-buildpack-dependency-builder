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
require 'build/dependency/node/node_inner'
require 'console_helper'

describe Build::Dependency::NodeInner do
  include_context 'console_helper'

  let(:options) { { configuration: 'spec/fixture/test_configuration.yml', version: 'test-version', tag: 'test-tag' } }

  let(:dependency) { described_class.new(options) }

  let(:source_location) { File.expand_path('vendor/node/source') }

  before { `pwd` }

  it 'should create codename and architecture qualified base_path' do
    expect(dependency).to receive(:codename).and_return('test-codename')
    expect(dependency).to receive(:architecture).and_return('test-architecture')

    expect(dependency.send(:base_path)).to eq('node/test-codename/test-architecture')
  end

  it 'should clone if the repository does not exist' do
    expect(File).to receive(:exist?).with(source_location).and_return false
    expect(Dir).to receive(:chdir).with(source_location).twice.and_call_original
    expect(dependency).to receive(:system).with("git clone https://github.com/joyent/node.git #{source_location}")
    expect(dependency).to receive(:system).with('git checkout test-tag')
    expect(dependency).to receive(:cpu_count).and_return('test-cpu-count')
    expect(dependency).to receive(:system).with(/make install/)

    expect(dependency.send(:source)).to be
  end

  it 'should update the repository if it does exist' do
    expect(File).to receive(:exist?).with(source_location).and_return true
    expect(Dir).to receive(:chdir).with(source_location).exactly(3).times.and_call_original
    expect(dependency).to receive(:system).with('git fetch origin')
    expect(dependency).to receive(:system).with('git clean -fdx')
    expect(dependency).to receive(:system).with('git reset --hard origin/master')
    expect(dependency).to receive(:system).with('git checkout test-tag')
    expect(dependency).to receive(:cpu_count).and_return('test-cpu-count')
    expect(dependency).to receive(:system).with(/make install/)

    expect(dependency.send(:source)).to be
  end

end
