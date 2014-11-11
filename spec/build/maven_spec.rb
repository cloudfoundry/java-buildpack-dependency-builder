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
require 'build/maven'

describe Build::Maven do

  let(:stub) { StubMaven.new }

  it 'should build snapshot URI for JAR' do
    expect(stub.snapshot StubMaven::MAVEN_CENTRAL, 'test.group.id', 'test-artifact-id', 'test-version')
      .to eq('http://central.maven.org/maven2/test/group/id/test-artifact-id/test-version.BUILD-SNAPSHOT/test-artifact-id-test-version.jar')
  end

  it 'should build snapshot URI for non-JAR' do
    expect(stub.snapshot StubMaven::MAVEN_CENTRAL, 'test.group.id', 'test-artifact-id', 'test-version', '.zip')
      .to eq('http://central.maven.org/maven2/test/group/id/test-artifact-id/test-version.BUILD-SNAPSHOT/test-artifact-id-test-version.zip')
  end

  it 'should build milestone URI for JAR' do
    expect(stub.milestone StubMaven::MAVEN_CENTRAL, 'test.group.id', 'test-artifact-id', 'test-version')
      .to eq('http://central.maven.org/maven2/test/group/id/test-artifact-id/test-version/test-artifact-id-test-version.jar')
  end

  it 'should build milestone URI for non-JAR' do
    expect(stub.milestone StubMaven::MAVEN_CENTRAL, 'test.group.id', 'test-artifact-id', 'test-version', '.zip')
      .to eq('http://central.maven.org/maven2/test/group/id/test-artifact-id/test-version/test-artifact-id-test-version.zip')
  end

  it 'should build release URI for JAR' do
    expect(stub.release StubMaven::MAVEN_CENTRAL, 'test.group.id', 'test-artifact-id', 'test-version')
      .to eq('http://central.maven.org/maven2/test/group/id/test-artifact-id/test-version/test-artifact-id-test-version.jar')
  end

  it 'should build release URI for non-JAR' do
    expect(stub.release StubMaven::MAVEN_CENTRAL, 'test.group.id', 'test-artifact-id', 'test-version', '.zip')
      .to eq('http://central.maven.org/maven2/test/group/id/test-artifact-id/test-version/test-artifact-id-test-version.zip')
  end

  class StubMaven
    include Build::Maven
  end

end
