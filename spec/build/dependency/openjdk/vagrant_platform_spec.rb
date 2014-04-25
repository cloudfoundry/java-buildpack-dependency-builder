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
require 'build/dependency/openjdk/vagrant_platform'
require 'English'

describe Build::Dependency::VagrantPlatform do

  let(:platform) { described_class.new('test-name', version) }

  before { `pwd` }

  context do
    let(:version) { '1.6.0' }

    it 'should start and stop vagrant and execute command for 1.6' do
      expect(Dir).to receive(:chdir).with(File.expand_path('resources/openjdk/6_and_7')).and_call_original
      expect(platform).to receive(:system).with('vagrant up test-name')
      expect(platform).to receive(:system).with("vagrant ssh test-name --command 'cd /java-buildpack-dependency-builder && test-command'")
      expect(platform).to receive(:system).with('vagrant destroy -f test-name')

      platform.exec('test-command')
    end
  end

  context do
    let(:version) { '1.7.0' }

    it 'should start and stop vagrant and execute command for 1.7' do
      expect(Dir).to receive(:chdir).with(File.expand_path('resources/openjdk/6_and_7')).and_call_original
      expect(platform).to receive(:system).with('vagrant up test-name')
      expect(platform).to receive(:system).with("vagrant ssh test-name --command 'cd /java-buildpack-dependency-builder && test-command'")
      expect(platform).to receive(:system).with('vagrant destroy -f test-name')

      platform.exec('test-command')
    end
  end

  context do
    let(:version) { '1.8.0' }

    it 'should start and stop vagrant and execute command for 1.8' do
      expect(Dir).to receive(:chdir).with(File.expand_path('resources/openjdk/8')).and_call_original
      expect(platform).to receive(:system).with('vagrant up test-name')
      expect(platform).to receive(:system).with("vagrant ssh test-name --command 'cd /java-buildpack-dependency-builder && test-command'")
      expect(platform).to receive(:system).with('vagrant destroy -f test-name')

      platform.exec('test-command')
    end
  end

  context do
    let(:version) { '1.5.0' }

    it 'should raise error for unknown version' do
      expect { platform.exec('test-command') }.to raise_error("Unable to process version '1.5.0'")
    end
  end

end
