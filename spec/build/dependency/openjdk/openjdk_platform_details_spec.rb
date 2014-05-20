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
require 'build/dependency/openjdk/openjdk_platform_details'

describe Build::Dependency::OpenJDKPlatformDetails do

  let(:stub) { StubOpenJDKPlatformDetails.new }

  it 'should return centos alt_bootdir' do
    expect(stub).to receive(:centos?).and_return(true)

    expect(stub.alt_bootdir).to eq('/usr/lib/jvm/java-1.6.0-openjdk.x86_64')
  end

  it 'should return macosx alt_bootdir' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(true)
    expect(ENV).to receive(:[]).with('JAVA6_HOME').and_return('test-java6-home')

    expect(stub.alt_bootdir).to eq('test-java6-home')
  end

  it 'should return trusty alt_bootdir' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:trusty?).and_return(true)

    expect(stub.alt_bootdir).to eq('/usr/lib/jvm/java-6-openjdk-amd64')
  end

  it 'should return ubuntu alt_bootdir' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:trusty?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(true)

    expect(stub.alt_bootdir).to eq('/usr/lib/jvm/java-6-openjdk')
  end

  it 'should fail for an unknown alt_bootdir' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:trusty?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(false)

    expect { stub.alt_bootdir }.to raise_error('Unable to determine ALT_BOOTDIR')
  end

  class StubOpenJDKPlatformDetails
    include Build::Dependency::OpenJDKPlatformDetails
  end

end
