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

    def initialize(root, name)
      root = Pathname.new(root)

      @content       = root + name
      @etag          = root + "#{name}.etag"
      @last_modified = root + "#{name}.last_modified"
    end

    def content
      if block_given?
        FileUtils.mkdir_p @content.dirname
        @content.open(File::CREAT | File::WRONLY) do |f|
          f.truncate 0
          yield f
          f.fsync
        end
      else
        @content.read
      end
    end

    def destroy
      [@content, @etag, @last_modified].each { |f| f.delete if f.exist? }
    end

    def etag
      @etag.read
    end

    def etag=(value)
      FileUtils.mkdir_p @etag.dirname
      write @etag, value
    end

    def etag?
      @etag.exist?
    end

    def last_modified
      @last_modified.read
    end

    def last_modified=(value)
      FileUtils.mkdir_p @last_modified.dirname
      write @last_modified, value
    end

    def last_modified?
      @last_modified.exist?
    end

    def path
      @content
    end

    private

    def write(file, value)
      file.open(File::CREAT | File::WRONLY) do |f|
        f.truncate 0
        f.write value
        f.fsync
      end
    end

  end
end
