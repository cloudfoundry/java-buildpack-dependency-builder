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
require 'pathname'
require 'replicate/replicated_file'
require 'tempfile'

describe Replicate::ReplicatedFile do

  it 'should return metadata if it exists' do
    replicated_file = described_class.new 'spec/fixture/replicated_file_with_metadata', 'foo'

    expect(replicated_file.etag?).to be
    expect(replicated_file.etag).to match(/test-etag/)

    expect(replicated_file.last_modified?).to be
    expect(replicated_file.last_modified).to match(/test-last-modified/)
  end

  it 'should not return metadata if it does not exist' do
    replicated_file = described_class.new 'spec/fixture/replicated_file_without_metadata', 'foo'

    expect(replicated_file.etag?).not_to be
    expect(replicated_file.last_modified?).not_to be
  end

  it 'should write metadata' do
    Dir.mktmpdir do |root|
      replicated_file = described_class.new root, 'foo'

      replicated_file.etag = 'test-etag'
      expect_file_content root, 'foo.etag', 'test-etag'

      replicated_file.last_modified = 'test-last-modified'
      expect_file_content root, 'foo.last_modified', 'test-last-modified'
    end
  end

  it 'should write content' do
    Dir.mktmpdir do |root|
      replicated_file = described_class.new root, 'foo'

      replicated_file.content { |f| f.write 'test-content' }
      expect(replicated_file.content).to match('test-content')
    end
  end

  it 'should expose path' do
    Dir.mktmpdir do |root|
      replicated_file = described_class.new root, 'foo'

      expect(replicated_file.path).to eq(Pathname.new(root) + 'foo')
    end
  end

  def expect_file_content(root, name, content)
    expect((Pathname.new(root) + name).read).to match(content)
  end

end
