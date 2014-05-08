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
require 'build/dependency/openjdk/local_platform'
require 'build/dependency/openjdk/openjdk'
require 'build/dependency/openjdk/openjdk_vagrant_platform'

describe Build::Dependency::OpenJDK do

  let(:options) do
    { configuration: 'spec/fixture/test_configuration.yml', version: 'test-version',
      build_number:  'test-build-number', tag: 'test-tag', platforms: %w(lucid osx) }
  end

  let(:dependency) { described_class.new(options) }

  it 'should execute on specified platforms' do
    expect_any_instance_of(Build::Dependency::OpenJDKVagrantPlatform)
    .to receive(:exec).with('bundle exec bin/build openjdk-inner ' \
                            '--configuration vendor/openjdk/java_buildpack_dependency_builder.yml ' \
                            '--version test-version ' \
                            '--build-number test-build-number ' \
                            '--tag test-tag ' \
                            '--development false')
    expect_any_instance_of(Build::Dependency::LocalPlatform)
    .to receive(:exec).with('bundle exec bin/build openjdk-inner ' \
                            '--configuration vendor/openjdk/java_buildpack_dependency_builder.yml ' \
                            '--version test-version ' \
                            '--build-number test-build-number ' \
                            '--tag test-tag ' \
                            '--development false')

    dependency.build
  end

  context do

    let(:options) do
      { configuration: 'spec/fixture/test_configuration.yml', version: 'test-version',
        build_number:  'test-build-number', tag: 'test-tag', platforms: %w(osx), development: 'true' }
    end

    it 'should execute with development' do
      expect_any_instance_of(Build::Dependency::LocalPlatform)
      .to receive(:exec).with('bundle exec bin/build openjdk-inner ' \
                            '--configuration vendor/openjdk/java_buildpack_dependency_builder.yml ' \
                            '--version test-version ' \
                            '--build-number test-build-number ' \
                            '--tag test-tag ' \
                            '--development true')

      dependency.build
    end
  end

end
