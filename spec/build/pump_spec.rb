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
require 'aws-sdk'
require 'build/pump'
require 'tempfile'

describe Build::Pump do
  include_context 'console_helper'

  let(:buffer) { double('buffer') }

  let(:destination) { double('destination', key: 'index.yml') }

  let(:source) { URI('http://test.host/test-path') }

  let(:source_headers) {}

  let(:pump) { Build::Pump.new 'test-tile', source, destination, source_headers, $stdout }

  it 'should pump from a URI' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirects for download if 301 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 301, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:get, 'http://alternate.test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirects for download if 302 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 302, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:get, 'http://alternate.test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirects for download if 303 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 303, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:get, 'http://alternate.test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirects for download if 307 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 307, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:get, 'http://alternate.test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirect for size if 301 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 301, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:head, 'http://alternate.test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirect for size if 302 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 302, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:head, 'http://alternate.test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirect for size if 303 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 303, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:head, 'http://alternate.test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should follow redirect for size if 307 returned' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 307, headers: { 'Location' => 'http://alternate.test.host/test-path' })
    stub_request(:head, 'http://alternate.test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    pump.pump
  end

  it 'should raise an error for a failed size' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 400)

    expect { pump.pump }.to raise_error("Unable to get size from 'http://test.host/test-path'.  Received '400'.")
  end

  it 'should raise an error for a failed download' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 400)

    expect { pump.pump }.to raise_error("Unable to download from 'http://test.host/test-path'.  Received '400'.")
  end

  context do
    let(:source) { double('source', key: 'index.yml', content_length: 100, exists?: true) }

    it 'should pump from an S3 object' do
      expect(source).to receive(:is_a?).with(URI).twice.and_return(false)
      expect(source).to receive(:is_a?).with(AWS::S3::S3Object).twice.and_return(true)
      expect(source).to receive(:read).and_yield('test-body')
      expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
      expect(buffer).to receive(:write).with('test-body')

      pump.pump
    end

  end

  context do
    let(:source) { double('source', key: 'index.yml', exists?: false) }

    it 'should not pump from a non-existent S3 object' do
      expect(source).to receive(:is_a?).with(URI).twice.and_return(false)
      expect(source).to receive(:is_a?).with(AWS::S3::S3Object).twice.and_return(true)
      expect(destination).to receive(:write).with(content_length: 0, content_type: 'text/x-yaml').and_yield(buffer, 1000)
      expect(buffer).to receive(:write).with(nil)

      pump.pump
    end
  end

  context do
    let(:source) { double('source') }

    it 'should fail if the source is not a URI or S3 object' do
      expect { pump.pump }.to raise_error(/Unable to download from/)
    end
  end

  context do
    let(:source) { 'spec/fixture/source_tempfile' }

    it 'should pump from a Tempfile object' do
      expect(source).to receive(:is_a?).with(URI).twice.and_return(false)
      expect(source).to receive(:is_a?).with(AWS::S3::S3Object).twice.and_return(false)
      expect(source).to receive(:is_a?).with(Tempfile).twice.and_return(true)
      expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
      expect(buffer).to receive(:write).with('test-body')

      pump.pump
    end

  end

  it 'should call provided block' do
    stub_request(:head, 'http://test.host/test-path')
      .to_return(status: 200, headers: { 'Content-Length' => '100' })
    stub_request(:get, 'http://test.host/test-path')
      .to_return(status: 200, body: 'test-body')
    expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
    expect(buffer).to receive(:write).with('test-body')

    expect { |b| pump.pump(&b) }.to yield_with_args
  end

  context do

    let(:source_headers) { { 'alpha' => 'bravo' } }

    it 'should utilize provided headers' do
      stub_request(:head, 'http://test.host/test-path')
        .with(headers: { 'alpha' => 'bravo' })
        .to_return(status: 200, headers: { 'Content-Length' => '100' })
      stub_request(:get, 'http://test.host/test-path')
        .with(headers: { 'alpha' => 'bravo' })
        .to_return(status: 200, body: 'test-body')
      expect(destination).to receive(:write).with(content_length: 9, content_type: 'text/x-yaml').and_yield(buffer, 1000)
      expect(buffer).to receive(:write).with('test-body')

      pump.pump
    end
  end

end
