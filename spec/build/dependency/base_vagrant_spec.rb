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
require 'build/dependency/base_vagrant'
require 'build/dependency/util/base_vagrant_platform'

describe Build::Dependency::BaseVagrant do

  let(:base_vagrant) { described_class.new 'test-command', Build::Dependency::BaseVagrantPlatform, options }

  let(:options) { { configuration: 'spec/fixture/test_configuration.yml', platforms: %w(lucid) } }

  it 'should raise error if arguments() is not implemented' do
    expect { base_vagrant.send(:arguments) }.to raise_error("Method 'arguments' must be defined")
  end

  it 'should execute on specified platforms' do
    expect(FileUtils).to receive(:rm_f).with(File.expand_path('vendor/java_buildpack_dependency_builder.yml'))
    expect(FileUtils).to receive(:cp).with(File.expand_path('spec/fixture/test_configuration.yml'),
                                           File.expand_path('vendor/java_buildpack_dependency_builder.yml'))
    expect(base_vagrant).to receive(:arguments).and_return(%w(test arguments))

    expect_any_instance_of(Build::Dependency::BaseVagrantPlatform)
    .to receive(:exec).with('bundle exec bin/build test-command ' \
                            '--configuration vendor/java_buildpack_dependency_builder.yml test arguments')

    base_vagrant.build
  end

end
