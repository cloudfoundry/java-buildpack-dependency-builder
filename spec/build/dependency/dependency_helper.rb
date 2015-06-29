# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
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

shared_context 'dependency_helper' do

  let(:options) { { configuration: 'spec/fixture/test_configuration.yml', version: 'test-version' } }

  let(:dependency) { described_class.new(options) }

  it 'should fail with an unknown version' do
    expect { dependency.send(:version_specific, 'unknown-version') }.to raise_error RuntimeError
  end

  def expect_version_uri(version, uri)
    proc = dependency.send(:version_specific, version)
    expect(proc.call(version)).to eq(uri)
  end

end
