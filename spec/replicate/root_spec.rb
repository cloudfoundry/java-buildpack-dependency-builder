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
require 'fileutils'
require 'replicate/object_collection'
require 'replicate/root'
require 'thread/pool'
require 'tmpdir'

describe Replicate::Root do
  include_context 'console_helper'

  let(:argv) { [] }

  let(:trigger) { Replicate::Root.start(argv) }

  it 'should display error message if no arguments are specified' do
    trigger

    expect(stderr.string).to match('--output')
  end

  context do
    let(:argv) { %w(--host-name test-host) }

    it 'should display error message if output is not specified' do
      trigger

      expect(stderr.string).not_to match('--base-uri')
      expect(stderr.string).not_to match('--host-name')
      expect(stderr.string).to match('--output')
    end
  end

  context do
    let(:argv) { %w(--output test-output) }

    it 'should display error message neither base-uri nor host-name is not specified' do
      trigger

      expect(stderr.string).to match('--base-uri')
      expect(stderr.string).to match('--host-name')
      expect(stderr.string).not_to match('--output')
    end
  end

  context do

    let(:argv) { ['--host-name', 'test-host', '--output', root] }

    let(:root) { Dir.mktmpdir }

    before { FileUtils.mkdir_p root }
    after { FileUtils.rm_rf root }

    it 'should replicate files' do
      stub_request(:get, 'http://download.pivotal.io.s3.amazonaws.com/')
        .to_return(status: 200, body: File.new('spec/fixture/object_collection_contents.xml'))
      stub_request(:get, 'https://download.run.pivotal.io:443/index.yml')
        .to_return(status: 200, body: 'start https://download.run.pivotal.io end')
      stub_request(:get, 'https://download.run.pivotal.io:443/artifact.jar')
        .to_return(status: 200, body: 'test-content')

      trigger

      expect(stdout.string).to match(/Complete /)
      expect_replicated_files root
      expect_file_content root, 'artifact.jar', 'test-content'
    end

    it 'should destroy a file when replication fails' do
      stub_request(:get, 'http://download.pivotal.io.s3.amazonaws.com/')
        .to_return(status: 200, body: File.new('spec/fixture/object_collection_contents.xml'))
      stub_request(:get, 'https://download.run.pivotal.io:443/index.yml')
        .to_return(status: 200, body: 'start https://download.run.pivotal.io end')
      stub_request(:get, 'https://download.run.pivotal.io:443/artifact.jar')
        .to_return(status: 400)

      expect { trigger }.to raise_error SystemExit

      expect_replicated_files root
      expect((Pathname.new(root) + 'artifact.jar')).not_to exist
      expect(stderr.string).to match(%r{FAILURE \(artifact.jar\): Unable to download from 'https://download.run.pivotal.io/artifact.jar'.  Received '400'.})
      expect(stderr.string).to match(/Incomplete/)
    end

    it 'should force a pool shutdown on SignalException' do
      stub_request(:get, 'http://download.pivotal.io.s3.amazonaws.com/')
        .to_return(status: 200, body: File.new('spec/fixture/object_collection_contents.xml'))
      stub_request(:get, 'https://download.run.pivotal.io/index.yml')
        .to_return(status: 200, body: 'start https://download.run.pivotal.io end')
      stub_request(:get, 'https://download.run.pivotal.io/artifact.jar')
        .to_return(status: 200, body: 'test-content')
      allow_any_instance_of(Thread::Pool).to receive(:shutdown).and_raise(SignalException.new('HUP'))
      expect_any_instance_of(Thread::Pool).to receive(:shutdown!)

      expect { trigger }.to raise_error SystemExit

      expect(stderr.string).to match(/Incomplete/)
    end
  end

  def expect_replicated_files(root)
    expect_file_content root, 'index.yml', 'start https://test-host end'
    expect_file_content root, 'index.yml.etag', '"8321b7a71f700608dbbd0db5e27ebcc2"'
    expect_file_content root, 'index.yml.last_modified', '2013-10-22 13:25:03 UTC'
  end

  def expect_file_content(root, name, content)
    expect((Pathname.new(root) + name).read).to match(content)
  end

end
