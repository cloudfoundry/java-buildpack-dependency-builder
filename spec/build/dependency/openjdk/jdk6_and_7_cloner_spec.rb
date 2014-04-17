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
require 'build/dependency/openjdk/jdk6_and_7_cloner'

describe Build::Dependency::JDK6And7Cloner do

  it 'should return patch list' do
    patches = described_class.new('foo', false).send(:patches)

    expect(patches).to include(File.expand_path('resources/openjdk/6_and_7/asound.diff'))
    expect(patches).to include(File.expand_path('resources/openjdk/6_and_7/leaf.diff'))
    expect(patches).to include(File.expand_path('resources/openjdk/6_and_7/sel.diff'))
    expect(patches).to include(File.expand_path('resources/openjdk/6_and_7/stat64.diff'))
  end

end
