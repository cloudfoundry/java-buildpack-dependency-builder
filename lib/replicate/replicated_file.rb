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

require 'fileutils'
require 'pathname'
require 'replicate'

module Replicate
  class ReplicatedFile
    include FileUtils

    def initialize(root, name)
      root           = Pathname.new(root)
      @content       = root + name
      @etag          = root + "#{name}.etag"
      @last_modified = root + "#{name}.last_modified"
    end

    def content(&block)
      if block_given?
        write_file @content, &block
      else
        @content.read
      end
    end

    def etag
      @etag.read
    end

    def etag=(value)
      mkdir_p @etag.dirname
      write @etag, value
    end

    def etag?
      @etag.exist?
    end

    def last_modified
      @last_modified.read
    end

    def last_modified=(value)
      mkdir_p @last_modified.dirname
      write @last_modified, value
    end

    def last_modified?
      @last_modified.exist?
    end

    def path
      @content
    end

    private

    def temp_file(file)
      Pathname.new(file.to_s + '.tmp')
    end

    def write(file, value)
      write_file(file) { |f| f.write value }
    end

    def write_file(file)
      mkdir_p file.dirname unless file.dirname.exist?

      temp_file(file).open(File::CREAT | File::WRONLY) do |temp|
        temp.truncate 0
        yield temp
        temp.fsync
        mv temp, file, force: true
      end
    end
  end
end
