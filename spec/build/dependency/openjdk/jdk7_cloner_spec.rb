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
require 'build/dependency/openjdk/jdk7_cloner'

describe Build::Dependency::JDK7Cloner do

  it 'should specify jdk7u repository' do
    cloner = described_class.new false
    expect(cloner.instance_variable_get(:@repository)).to eq('http://hg.openjdk.java.net/jdk7u/jdk7u')
  end

  it 'should specify jdk7u-dev repository' do
    cloner = described_class.new true
    expect(cloner.instance_variable_get(:@repository)).to eq('http://hg.openjdk.java.net/jdk7u/jdk7u-dev')
  end

end
