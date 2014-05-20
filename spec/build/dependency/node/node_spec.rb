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
require 'build/dependency/node/node'

describe Build::Dependency::Node do

  let(:dependency) { described_class.new(options) }

  let(:options) { { version: 'test-version', tag: 'test-tag', platforms: [] } }

  it 'should execute without development' do
    expect(dependency.send(:arguments)).to include('--version test-version', '--tag test-tag')
  end

end
