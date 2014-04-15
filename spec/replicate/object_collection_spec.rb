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
require 'replicate/object_collection'

describe Replicate::ObjectCollection do

  let(:object_collection) { described_class.new }

  it 'should create a collection with two elements' do
    stub_request(:get, 'http://download.pivotal.io.s3.amazonaws.com/')
    .to_return(status: 200, body: File.new('spec/fixture/object_collection_contents.xml'))

    expect(object_collection[0].key).to eq 'index.yml'
    expect(object_collection[1].key).to eq 'artifact.jar'
  end

end
