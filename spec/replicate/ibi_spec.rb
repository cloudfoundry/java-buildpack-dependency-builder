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
require 'replicate/ibi'

describe 'format size' do

  it 'should display bytes' do
    expect_size_string '1 B', BYTE
  end

  it 'should display kibibytes' do
    expect_size_string '1.0 KiB', KIBI
    expect_size_string '1.0 KiB', KIBI + BYTE
  end

  it 'should display mibibytes' do
    expect_size_string '1.0 MiB', MIBI
    expect_size_string '1.0 MiB', MIBI + KIBI
    expect_size_string '1.0 MiB', MIBI + KIBI + BYTE
  end

  it 'should display gibibytes' do
    expect_size_string '1.0 GiB', GIBI
    expect_size_string '1.0 GiB', GIBI + MIBI
    expect_size_string '1.0 GiB', GIBI + MIBI + KIBI
    expect_size_string '1.0 GiB', GIBI + MIBI + KIBI + BYTE
  end

  private

  BYTE = 1

  KIBI = (1024 * BYTE).freeze

  MIBI = (1024 * KIBI).freeze

  GIBI = (1024 * MIBI).freeze

  def expect_size_string(expected, size)
    expect(size.ibi).to eq(expected)
  end

end
