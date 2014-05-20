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
require 'build/mmmq_normalizer'

describe Build::MMMQNormalizer do

  let(:stub) { StubMMQNormalizer.new }

  it 'should remove qualifier from version with qualifier' do
    expect(stub.non_qualifier_version '1.2.3.QUALIFIER').to eq('1.2.3')
  end

  it 'should return original for version without qualifier' do
    expect(stub.non_qualifier_version '1.2.3').to eq('1.2.3')
  end

  it 'should return original for version with less than 3 numbers' do
    expect(stub.non_qualifier_version '1.2').to eq('1.2')
  end

  it 'should replace qualifier . with _' do
    expect(stub.normalize '1.2.3.QUALIFIER').to eq('1.2.3_QUALIFIER')
  end

  it 'should return original for version without qualifier' do
    expect(stub.normalize '1.2.3').to eq('1.2.3')
  end

  it 'should return original for version with less than 3 numbers' do
    expect(stub.normalize '1.2').to eq('1.2')
  end

  class StubMMQNormalizer
    include Build::MMMQNormalizer
  end

end
