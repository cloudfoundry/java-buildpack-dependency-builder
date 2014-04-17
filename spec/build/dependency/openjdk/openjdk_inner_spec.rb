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
require 'build/dependency/openjdk/ca_certs_builder'
require 'build/dependency/openjdk/jdk6_cloner'
require 'build/dependency/openjdk/jdk7_cloner'
require 'build/dependency/openjdk/jdk8_cloner'
require 'build/dependency/openjdk/jdk8_bootstrap_jdk_builder'
require 'build/dependency/openjdk/jre6_and_7_jre_builder'
require 'build/dependency/openjdk/jre8_jre_builder'
require 'build/dependency/openjdk/openjdk_inner'
require 'build/dependency/openjdk/noop_bootstrap_jdk_builder'

describe Build::Dependency::OpenJDKInner do

  let(:options) do
    { configuration: 'spec/fixture/test_configuration.yml', version: 'test-version',
      build_number:  'test-build-number', tag: 'test-tag' }
  end

  let(:dependency) { described_class.new(options) }

  it 'should create codename and architecture qualified base_path' do
    expect(dependency).to receive(:codename).and_return('test-codename')
    expect(dependency).to receive(:architecture).and_return('test-architecture')

    expect(dependency.send(:base_path)).to eq('openjdk/test-codename/test-architecture')
  end

  context do
    let(:options) do
      { configuration: 'spec/fixture/test_configuration.yml', version: '1.6.0',
        build_number:  'test-build-number', tag: 'test-tag' }
    end

    it 'should build a 1.6 JRE' do
      expect_any_instance_of(Build::Dependency::NoOpBootstrapJDKBuilder).to receive(:build)
      expect_any_instance_of(Build::Dependency::CACertsBuilder).to receive(:build)
      expect_any_instance_of(Build::Dependency::JDK6Cloner).to receive(:clone)
      expect_any_instance_of(Build::Dependency::JDK6Cloner).to receive(:checkout_tag).with('test-tag')
      expect_any_instance_of(Build::Dependency::JDK6Cloner).to receive(:apply_patches)
      expect_any_instance_of(Build::Dependency::JRE6And7JREBuilder).to receive(:build)

      expect(dependency.send(:source)).to be
    end
  end

  context do
    let(:options) do
      { configuration: 'spec/fixture/test_configuration.yml', version: '1.7.0',
        build_number:  'test-build-number', tag: 'test-tag' }
    end

    it 'should build a 1.7 JRE' do
      expect_any_instance_of(Build::Dependency::NoOpBootstrapJDKBuilder).to receive(:build)
      expect_any_instance_of(Build::Dependency::CACertsBuilder).to receive(:build)
      expect_any_instance_of(Build::Dependency::JDK7Cloner).to receive(:clone)
      expect_any_instance_of(Build::Dependency::JDK7Cloner).to receive(:checkout_tag).with('test-tag')
      expect_any_instance_of(Build::Dependency::JDK7Cloner).to receive(:apply_patches)
      expect_any_instance_of(Build::Dependency::JRE6And7JREBuilder).to receive(:build)

      expect(dependency.send(:source)).to be
    end
  end

  context do
    let(:options) do
      { configuration: 'spec/fixture/test_configuration.yml', version: '1.8.0',
        build_number:  'test-build-number', tag: 'test-tag' }
    end

    it 'should build a 1.8 JRE' do
      expect_any_instance_of(Build::Dependency::JDK8BootstrapJDKBuilder).to receive(:build)
      expect_any_instance_of(Build::Dependency::CACertsBuilder).to receive(:build)
      expect_any_instance_of(Build::Dependency::JDK8Cloner).to receive(:clone)
      expect_any_instance_of(Build::Dependency::JDK8Cloner).to receive(:checkout_tag).with('test-tag')
      expect_any_instance_of(Build::Dependency::JDK8Cloner).to receive(:apply_patches)
      expect_any_instance_of(Build::Dependency::JRE8JREBuilder).to receive(:build)

      expect(dependency.send(:source)).to be
    end
  end

  context do
    let(:options) do
      { configuration: 'spec/fixture/test_configuration.yml', version: 'unknown-version',
        build_number:  'test-build-number', tag: 'test-tag' }
    end

    it 'should not build an unknown JRE' do
      expect { dependency.send(:source) }.to raise_error("Unable to process version 'unknown-version'")
    end
  end

end
