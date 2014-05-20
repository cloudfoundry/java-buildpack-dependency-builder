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
require 'build/dependency/openjdk/openjdk_resources'

describe Build::Dependency::OpenJDKResources do

  it 'should calculate RESOURCES_DIR' do
    expect(StubOpenJDKResources::RESOURCES_DIR).to eq(File.expand_path('resources/openjdk'))
  end

  it 'should calculate VENDOR_DIR' do
    expect(StubOpenJDKResources::VENDOR_DIR).to eq(File.expand_path('vendor/openjdk'))
  end

  class StubOpenJDKResources
    include Build::Dependency::OpenJDKResources
  end

end
