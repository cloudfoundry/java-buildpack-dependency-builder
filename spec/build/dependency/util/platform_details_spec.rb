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
require 'build/dependency/util/platform_details'

describe Build::Dependency::PlatformDetails do

  let(:stub) { StubPlatformDetails.new }

  it 'should return the architecture' do
    expect(stub).to receive(:`).with('uname -m').and_return('test-architecture')

    expect(stub.architecture).to eq('test-architecture')
  end

  it 'should return the centos6 codename' do
    expect(stub).to receive(:centos?).and_return(true)
    expect(File).to receive(:open).with('/etc/redhat-release', 'r').and_yield(File.open('spec/fixture/redhat-release'))

    expect(stub.codename).to eq('centos1')
  end

  it 'should return the macosx codename' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(true)

    expect(stub.codename).to eq('mountainlion')
  end

  it 'should return the ubuntu codename' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(true)
    expect(stub).to receive(:`).with('lsb_release -cs').and_return('test-codename')

    expect(stub.codename).to eq('test-codename')
  end

  it 'should fail for an unknown codename' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(false)

    expect { stub.codename }.to raise_error('Unable to determine codename')
  end

  it 'should return cpu count for centos' do
    expect(stub).to receive(:centos?).and_return(true)
    expect(stub).to receive(:`).with('nproc').and_return('test-cpu-count')

    expect(stub.cpu_count).to eq('test-cpu-count')

  end

  it 'should return cpu count for macosx' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(true)
    expect(stub).to receive(:`).with('sysctl -n hw.ncpu').and_return('test-cpu-count')

    expect(stub.cpu_count).to eq('test-cpu-count')
  end

  it 'should return cpu count for ubuntu' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(true)
    expect(stub).to receive(:`).with('grep -c "processor" /proc/cpuinfo').and_return('test-cpu-count')

    expect(stub.cpu_count).to eq('test-cpu-count')
  end

  it 'should fail for an unknown cpu count' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(false)

    expect { stub.cpu_count }.to raise_error('Unable to determine cpu count')
  end

  it 'should detect centos6' do
    expect(File).to receive(:exist?).with('/etc/redhat-release').and_return(true)

    expect(stub.centos?).to be
  end

  it 'should not detect centos6' do
    expect(File).to receive(:exist?).with('/etc/redhat-release').and_return(false)

    expect(stub.centos?).not_to be
  end

  it 'should detect macosx' do
    expect(stub).to receive(:`).with('uname -s').and_return('Darwin')

    expect(stub.macosx?).to be
  end

  it 'should not detect macosx' do
    expect(stub).to receive(:`).with('uname -s').and_return('other')

    expect(stub.macosx?).not_to be
  end

  it 'should detect trusty' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(true)
    expect(stub).to receive(:`).with('lsb_release -cs').and_return('trusty')

    expect(stub.trusty?).to be
  end

  it 'should not detect trusty' do
    expect(stub).to receive(:centos?).and_return(false)
    expect(stub).to receive(:macosx?).and_return(false)
    expect(stub).to receive(:ubuntu?).and_return(true)
    expect(stub).to receive(:`).with('lsb_release -cs').and_return('test-codename')

    expect(stub.trusty?).not_to be
  end

  it 'should detect ubuntu' do
    expect(stub).to receive(:`).with('which lsb_release 2> /dev/null').and_return('content')

    expect(stub.ubuntu?).to be
  end

  it 'should not detect ubuntu' do
    expect(stub).to receive(:`).with('which lsb_release 2> /dev/null').and_return('')

    expect(stub.ubuntu?).not_to be
  end

  class StubPlatformDetails
    include Build::Dependency::PlatformDetails
  end

end
