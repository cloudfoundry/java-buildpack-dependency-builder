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
require 'build/dependency/util/base_vagrant_platform'
require 'English'

describe Build::Dependency::BaseVagrantPlatform do

  let(:platform) { described_class.new 'test-name', 'test-version', false }

  before { `pwd` }

  it 'should properly identify vagrant platforms' do
    expect(described_class.vagrant? 'centos6').to be
    expect(described_class.vagrant? 'lucid').to be
    expect(described_class.vagrant? 'osx').not_to be
    expect(described_class.vagrant? 'precise').to be
    expect(described_class.vagrant? 'trusty').to be
  end

  it 'should raise error if version_specific() method is not implemented' do
    expect { platform.send(:version_specific, '') }.to raise_error("Method 'version_specific(version)' must be defined")
  end

  it 'should start and stop vagrant and execute command' do
    expect(platform).to receive(:version_specific).with('test-version').and_return('spec/fixture')
    expect(Dir).to receive(:chdir).with('spec/fixture').and_call_original
    expect(platform).to receive(:system).with('vagrant up test-name')
    expect(platform).to receive(:system).with("vagrant ssh test-name --command 'cd /java-buildpack-dependency-builder && test-command'")

    platform.exec('test-command')
  end

  context do

    let(:platform) { described_class.new 'test-name', 'test-version', true }

    it 'should start and execute command if shutdown is true' do
      expect(platform).to receive(:version_specific).with('test-version').and_return('spec/fixture')
      expect(Dir).to receive(:chdir).with('spec/fixture').and_call_original
      expect(platform).to receive(:system).with('vagrant up test-name')
      expect(platform).to receive(:system).with("vagrant ssh test-name --command 'cd /java-buildpack-dependency-builder && test-command'")
      expect(platform).to receive(:system).with('vagrant destroy -f test-name')

      platform.exec('test-command')
    end

  end

end
