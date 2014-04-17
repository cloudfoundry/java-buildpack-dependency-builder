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
require 'aws-sdk'
require 'build/dependency/dependency_helper'
require 'build/dependency/base'
require 'build/invalidator'
require 'build/pump'
require 'tempfile'
require 'yaml'

describe Build::Dependency::Base do
  include_context 'dependency_helper'

  let(:dependency) { described_class.new('test-name', 'test-type', options) }

  let(:pump) { double('pump') }

  it 'should build dependency' do
    Tempfile.open('spec') do |file|
      expect(dependency).to receive(:version_specific).with('test-version').and_return(->(_v) { 'http://test/uri' })

      expect(pump).to receive(:pump)
      expect(pump).to receive(:pump).and_yield file

      expect(Build::Pump).to receive(:new) do |title, source, destination, headers|
        expect(title).to eq('test-name test-version')
        expect(source).to eq(URI('http://test/uri'))
        expect(destination.key).to eq('test-name/test-name-test-version.test-type')
        expect(headers).not_to be

        pump
      end

      expect(Build::Pump).to receive(:new) do |title, source, destination, headers, &_block|
        expect(title).to eq('test-name index')
        expect(source.key).to eq('test-name/index.yml')
        expect(destination.key).to eq('test-name/index.yml')
        expect(headers).not_to be

        pump
      end

      expect_any_instance_of(Build::Invalidator).to receive(:with_invalidation) do |_invalidator, object, &block|
        expect(object.key).to eq('test-name/test-name-test-version.test-type')
        block.call
      end

      expect_any_instance_of(Build::Invalidator).to receive(:with_invalidation) do |_invalidator, object, &block|
        expect(object.key).to eq('test-name/index.yml')
        block.call
      end

      dependency.build

      expect(YAML.load_file file)
      .to eq('test-version' => 'http://test.repository.root/test-name/test-name-test-version.test-type')
    end
  end

  it 'should fail if version_specific(version) not implemented' do
    expect { dependency.send(:version_specific, 'test-version') }.to raise_error("Method 'version_specific(version)' must be defined")
  end

end
