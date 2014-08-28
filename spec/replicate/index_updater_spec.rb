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
require 'pathname'
require 'replicate/index_updater'

describe Replicate::IndexUpdater do

  let(:file) { double('File') }

  let(:replicated_file) { double('ReplicatedFile') }

  let(:index_updater) { described_class.new nil, 'test-host' }

  it 'should replace base uri in index file' do
    expect(replicated_file).to receive(:path).and_return(Pathname.new('index.yml'))
    expect(replicated_file).to receive(:content).with(no_args).and_return('start https://download.run.pivotal.io end')
    expect(replicated_file).to receive(:content).with(no_args).and_yield(file)
    expect(file).to receive(:write).with('start http://test-host end')

    index_updater.update replicated_file
  end

  it 'should not replace host name in other file' do
    expect(replicated_file).to receive(:path).and_return(Pathname.new('index.html'))
    expect(replicated_file).not_to receive(:content)

    index_updater.update replicated_file
  end

  it 'should fail if neither base_uri nor host_name are specified' do
    expect { described_class.new nil, nil }.to raise_error(/No value provided for one of required options '--base-uri', '--host-name/)
  end

  it 'should fail id both base_uri and host_name are specified' do
    expect { described_class.new 'test-base-uri', 'test-host-name' }.to raise_error(/Only value can be provided for one of required options '--base-uri', '--host-name'/)
  end

  context do

    let(:index_updater) { described_class.new 'https://test-host', nil }

    it 'should replace base uri in index file' do
      expect(replicated_file).to receive(:path).and_return(Pathname.new('index.yml'))
      expect(replicated_file).to receive(:content).with(no_args).and_return('start https://download.run.pivotal.io end')
      expect(replicated_file).to receive(:content).with(no_args).and_yield(file)
      expect(file).to receive(:write).with('start https://test-host end')

      index_updater.update replicated_file
    end

    it 'should not replace base uri in other file' do
      expect(replicated_file).to receive(:path).and_return(Pathname.new('index.html'))
      expect(replicated_file).not_to receive(:content)

      index_updater.update replicated_file
    end
  end

end
