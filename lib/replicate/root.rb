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
require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'replicate'
require 'replicate/duration'
require 'replicate/ibi'
require 'replicate/object'
require 'thor'
require 'thread/pool'

module Replicate

  class Root < Thor

    desc '[OPTIONS]', 'Replicate the Java Buildpack Dependency Cache to the local filesystem'

    option :host_name,
           desc:     'The hostname to use inside index.yml files',
           aliases:  '-h',
           required: true

    option :number_of_downloads,
           desc:    'The number of parallel downloads',
           aliases: '-n',
           type:    :numeric,
           default: 50

    option :output,
           desc:     'The output location for the replicated cache',
           aliases:  '-o',
           required: true

    def replicate
      init_output

      pool = Thread.pool(options[:number_of_downloads])
      begin
        with_replicate_timing do
          items.each { |object| pool.process { process object } }
          pool.shutdown
        end
      rescue SignalException
        puts "\nInterrupted"
        pool.shutdown!
      end
    end

    private

    ROOT = 'http://download.pivotal.io.s3.amazonaws.com/'.freeze

    HOST_NAME = 'download.run.pivotal.io'.freeze

    INDEX_FILE = Pathname.new 'index.yml'.freeze

    private_constant :ROOT, :HOST_NAME, :INDEX_FILE

    default_task :replicate

    def init_output
      FileUtils.rm_rf options[:output]
      FileUtils.mkdir_p options[:output]
    end

    def items
      doc = Nokogiri::XML(open(ROOT))

      doc.xpath('./xmlns:ListBucketResult/xmlns:Contents').map { |contents| Object.new(contents) }
      .select { |object| object.key !~ /\/$/ }
    end

    def process(object)
      path      = Pathname.new(options[:output]) + object.key
      host_name = options[:host_name]

      with_cleanup(object, path) do
        with_object_timing(object) do
          FileUtils.mkdir_p path.dirname
          File.open(path, 'wb') { |file| object.read { |chunk| file.write(chunk) } }
          File.utime(object.last_modified, object.last_modified, path)
        end

        replace_host_name(path, host_name) if path.basename == INDEX_FILE
      end
    end

    def replace_host_name(path, host_name)
      content = path.read.gsub(/#{HOST_NAME}/, host_name)
      path.open('w') do |file|
        file.write content
      end
    end

    def with_cleanup(object, path)
      yield
    rescue => e
      FileUtils.rm_rf path
      print "FAILURE (#{object.key}): #{e}\n"
    end

    def with_object_timing(object)
      download_start_time = Time.now
      yield
      print "#{object.key} (#{object.content_length.ibi} => #{(Time.now - download_start_time).duration})\n"
    end

    def with_replicate_timing
      download_start_time = Time.now
      yield
      print "\nComplete (#{(Time.now - download_start_time).duration})\n"
    end

  end

end
