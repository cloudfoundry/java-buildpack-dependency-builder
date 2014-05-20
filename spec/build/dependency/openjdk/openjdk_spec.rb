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
require 'build/dependency/openjdk/openjdk'
require 'build/dependency/util/local_platform'

describe Build::Dependency::OpenJDK do

  let(:dependency) { described_class.new(options) }

  context do
    let(:options) do
      { version: 'test-version', build_number: 'test-build-number', tag: 'test-tag', platforms: [] }
    end

    it 'should execute without development' do
      expect(dependency.send(:arguments)).to include('--version test-version', '--build-number test-build-number',
                                                     '--tag test-tag', '--development false')
    end
  end

  context do
    let(:options) do
      { version: 'test-version', build_number: 'test-build-number', tag: 'test-tag', development: 'true', platforms: [] }
    end

    it 'should execute with development' do
      expect(dependency.send(:arguments)).to include('--version test-version', '--build-number test-build-number',
                                                     '--tag test-tag', '--development true')
    end
  end

end
