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

  let(:index_updater) { described_class.new 'test-host' }

  it 'should replace host in index file' do
    expect(replicated_file).to receive(:path).and_return(Pathname.new('index.yml'))
    expect(replicated_file).to receive(:content).with(no_args).and_return('start download.run.pivotal.io end')
    expect(replicated_file).to receive(:content).with(no_args).and_yield(file)
    expect(file).to receive(:write).with('start test-host end')

    index_updater.update replicated_file
  end

  it 'should not replace host in other file' do
    expect(replicated_file).to receive(:path).and_return(Pathname.new('index.html'))
    expect(replicated_file).not_to receive(:content)

    index_updater.update replicated_file
  end

end
