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
require 'console_helper'
require 'environment_helper'
require 'net/http'
require 'open-uri'
require 'replicate/object'
require 'replicate/replicated_file'
require 'tempfile'

describe Replicate::Object do
  include_context 'console_helper'
  include_context 'environment_helper'

  let(:contents) { Nokogiri::XML(open('spec/fixture/object_contents.xml')).children.first }

  let(:object) { described_class.new contents }

  it 'should replicate file' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .to_return(status: 200, body: 'test-content')

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect_replicated_files root
    end
  end

  it 'should attempt to 304 if etag and last_modified exist' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .with(headers: { 'If-None-Match' => 'old-etag', 'If-Modified-Since' => '2013-01-01 00:00:00 UTC' })
      .to_return(status: 200, body: 'test-content')

      write_replicated_files root

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect_replicated_files root
      expect(stdout.string).to match(/index.yml \(6.0 MiB => 0.0s\)/)
    end
  end

  it 'should not update if 304 returned' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .with(headers: { 'If-None-Match' => 'old-etag', 'If-Modified-Since' => '2013-01-01 00:00:00 UTC' })
      .to_return(status: 304)

      write_replicated_files root

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect(stdout.string).to match(/index.yml \(6.0 MiB => up to date\)/)
    end
  end

  it 'should follow redirect if 301 returned' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .to_return(status: 301, headers: { Location: 'http://test-host/test-path' })
      stub_request(:get, 'http://test-host/test-path')
      .to_return(status: 200, body: 'test-content')

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect_replicated_files root
      expect(stdout.string).to match(/index.yml \(6.0 MiB =>/)
    end
  end

  it 'should follow redirect if 302 returned' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .to_return(status: 302, headers: { Location: 'http://test-host/test-path' })
      stub_request(:get, 'http://test-host/test-path')
      .to_return(status: 200, body: 'test-content')

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect_replicated_files root
      expect(stdout.string).to match(/index.yml \(6.0 MiB =>/)
    end
  end

  it 'should follow redirect if 303 returned' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .to_return(status: 303, headers: { Location: 'http://test-host/test-path' })
      stub_request(:get, 'http://test-host/test-path')
      .to_return(status: 200, body: 'test-content')

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect_replicated_files root
      expect(stdout.string).to match(/index.yml \(6.0 MiB =>/)
    end
  end

  it 'should follow redirect if 307 returned' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .to_return(status: 307, headers: { Location: 'http://test-host/test-path' })
      stub_request(:get, 'http://test-host/test-path')
      .to_return(status: 200, body: 'test-content')

      object.replicate Replicate::ReplicatedFile.new(root, object.key)

      expect_replicated_files root
      expect(stdout.string).to match(/index.yml \(6.0 MiB =>/)
    end
  end

  it 'should fail if anything else is returned' do
    Dir.mktmpdir do |root|
      stub_request(:get, 'http://download.run.pivotal.io/index.yml')
      .to_return(status: 400)

      expect { object.replicate Replicate::ReplicatedFile.new(root, object.key) }
      .to raise_error("Unable to download from 'http://download.run.pivotal.io/index.yml'.  Received '400'.")
    end
  end

  context do

    let(:environment) { { 'http_proxy' => 'http://proxy:9000' } }

    it 'should use http_proxy if specified' do
      Dir.mktmpdir do |root|
        stub_request(:get, 'http://download.run.pivotal.io/index.yml')
        .to_return(status: 200, body: 'test-content')

        allow(Net::HTTP).to receive(:Proxy).and_call_original
        expect(Net::HTTP).to receive(:Proxy).with('proxy', 9000, nil, nil).and_call_original

        object.replicate Replicate::ReplicatedFile.new(root, object.key)
      end
    end

  end

  context do

    let(:environment) { { 'HTTP_PROXY' => 'http://proxy:9000' } }

    it 'should use HTTP_PROXY if specified' do
      Dir.mktmpdir do |root|
        stub_request(:get, 'http://download.run.pivotal.io/index.yml')
        .to_return(status: 200, body: 'test-content')

        allow(Net::HTTP).to receive(:Proxy).and_call_original
        expect(Net::HTTP).to receive(:Proxy).with('proxy', 9000, nil, nil).and_call_original

        object.replicate Replicate::ReplicatedFile.new(root, object.key)
      end
    end

  end

  def expect_replicated_files(root)
    expect_file_content root, 'index.yml', 'test-content'
    expect_file_content root, 'index.yml.etag', '"8321b7a71f700608dbbd0db5e27ebcc2"'
    expect_file_content root, 'index.yml.last_modified', '2013-10-22 13:25:03 UTC'
  end

  def expect_file_content(root, name, content)
    expect((Pathname.new(root) + name).read).to match(content)
  end

  def write_replicated_files(root)
    write_file_content root, 'index.yml', 'old-test-content'
    write_file_content root, 'index.yml.etag', 'old-etag'
    write_file_content root, 'index.yml.last_modified', '2013-01-01 00:00:00 UTC'
  end

  def write_file_content(root, name, content)
    (Pathname.new(root) + name).open('w') do |f|
      f.write content
      f.fsync
    end
  end

end
