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
require 'build/dependency/dependency_helper'
require 'build/dependency/spring_boot_cli'

describe Build::Dependency::SpringBootCLI do
  include_context 'dependency_helper'

  it 'should create Spring Boot CLI BUILD URI' do
    expect_version_uri '1.0.0.BUILD-123', 'http://repo.spring.io/libs-snapshot-local/org/springframework/boot/spring-boot-cli/1.0.0.BUILD-SNAPSHOT/spring-boot-cli-1.0.0.BUILD-123-bin.tar.gz'
  end

  it 'should create Spring Boot CLI M URI' do
    expect_version_uri '1.0.0.M8', 'http://repo.spring.io/milestone/org/springframework/boot/spring-boot-cli/1.0.0.M8/spring-boot-cli-1.0.0.M8-bin.tar.gz'
  end

  it 'should create Spring Boot CLI RC URI' do
    expect_version_uri '1.0.0.RC1', 'http://repo.spring.io/milestone/org/springframework/boot/spring-boot-cli/1.0.0.RC1/spring-boot-cli-1.0.0.RC1-bin.tar.gz'
  end

  it 'should create Spring Boot CLI RELEASE URI' do
    expect_version_uri '1.0.0.RELEASE', 'http://repo.spring.io/release/org/springframework/boot/spring-boot-cli/1.0.0.RELEASE/spring-boot-cli-1.0.0.RELEASE-bin.tar.gz'
  end

  it 'should return the MMMQ for normalized' do
    expect(dependency.send(:normalize, '1.0.0.RELEASE')).to eq('1.0.0_RELEASE')
  end

end
