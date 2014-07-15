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
require 'build/dependency/openjdk/base_cloner'
require 'English'

describe Build::Dependency::BaseCloner do
  include_context 'console_helper'

  let(:cloner) { described_class.new 'test/repo', false }

  let(:hgrc) { File.join ENV['HOME'], '/.hgrc' }

  let(:source_location) { File.expand_path 'vendor/openjdk/source/repo' }

  before { `pwd` }

  it 'should expose source location' do
    expect(described_class.new('test/repo', false).source_location).to eq(source_location)
  end

  it 'should build repository' do
    repository = described_class.new('test/repo', false).instance_variable_get(:@repository)
    expect(repository).to eq('test/repo')
  end

  it 'should build dev repository' do
    repository = described_class.new('test/repo', true).instance_variable_get(:@repository)
    expect(repository).to eq('test/repo-dev')
  end

  it 'should clone if repo does not exist' do
    expect(File).to receive(:exist?).with(hgrc).and_return(false)
    expect(File).to receive(:open).with(hgrc, 'w')

    expect(File).to receive(:exist?).with(source_location).and_return(false)
    expect(FileUtils).to receive(:mkdir_p).with(source_location)
    expect(cloner).to receive(:system).with("hg clone test/repo #{source_location}")

    expect(Dir).to receive(:chdir).with(source_location).and_yield
    expect(cloner).to receive(:system).with('chmod +x get_source.sh make/scripts/hgforest.sh')
    expect(cloner).to receive(:system).with('./get_source.sh')

    cloner.clone
  end

  it 'should update if repo does exist' do
    expect(File).to receive(:exist?).with(hgrc).and_return(false)
    expect(File).to receive(:open).with(hgrc, 'w')

    expect(File).to receive(:exist?).with(source_location).and_return(true)
    expect(Dir).to receive(:chdir).with(source_location).and_yield
    expect(cloner).to receive(:system).with('chmod +x make/scripts/hgforest.sh').twice
    expect(cloner).to receive(:system).with('make/scripts/hgforest.sh purge --all')
    expect(cloner).to receive(:system).with('make/scripts/hgforest.sh update --clean')

    cloner.clone
  end

  it 'should checkout a tag' do
    expect(Dir).to receive(:chdir).with(source_location).and_yield
    expect(cloner).to receive(:system).with('make/scripts/hgforest.sh checkout --clean test-tag')

    cloner.checkout_tag 'test-tag'
  end

  it 'should apply patches' do
    expect(Dir).to receive(:chdir).and_yield
    expect(cloner).to receive(:patches).and_return(['test-patch'])
    expect(cloner).to receive(:system).with('patch -N -p0 -i test-patch')

    cloner.apply_patches
  end

  it 'should default to no patches' do
    expect(cloner.send(:patches)).to be_empty
  end

end
