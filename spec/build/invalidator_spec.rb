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
require 'build/invalidator'

describe Build::Invalidator do
  include_context 'console_helper'

  let(:client) { double('Client') }

  let(:distribution_id) { 'distribution-id' }

  let(:invalidator) { described_class.new double('CloudFront', client: client), distribution_id, $stdout }

  let(:object) { double('Object') }

  it 'should not invalidate if object did not exist' do
    expect(object).to receive(:exists?).and_return(false)
    expect(client).not_to receive(:create_invalidation)

    expect { |b| invalidator.with_invalidation(object, &b) }.to yield_with_no_args
  end

  context do
    let(:distribution_id) { nil }

    it 'should not invalidate if distribution_id is not specified' do
      expect(object).to receive(:exists?).and_return(true)
      expect(client).not_to receive(:create_invalidation)

      expect { |b| invalidator.with_invalidation(object, &b) }.to yield_with_no_args
    end
  end

  it 'should invalidate id object exists and distribution_id is specified' do
    expect(object).to receive(:exists?).and_return(true)
    expect(object).to receive(:key).and_return('test-key')
    expect(client).to receive(:create_invalidation) do |arg|
      expect(arg[:invalidation_batch][:paths][:items].first).to eq('/test-key')
      sleep 0.5
    end
    expect_any_instance_of(ProgressBar::Base).to receive(:increment).at_least(:once)

    expect { |b| invalidator.with_invalidation(object, &b) }.to yield_with_no_args
  end

end
