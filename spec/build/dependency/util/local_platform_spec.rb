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
require 'build/dependency/util/local_platform'

describe Build::Dependency::LocalPlatform do

  let(:platform) { described_class.new }

  it 'should change directory and execute command' do
    expect(Dir).to receive(:chdir).with(File.expand_path('.')).and_call_original
    expect(platform).to receive(:system).with('test-command')

    platform.exec('test-command')
  end

end
