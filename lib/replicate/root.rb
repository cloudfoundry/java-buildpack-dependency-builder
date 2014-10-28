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
require 'replicate/duration'
require 'replicate/ibi'
require 'replicate/index_updater'
require 'replicate/object_collection'
require 'replicate/replicated_file'
require 'thor'
require 'thread/future'
require 'thread/pool'

module Replicate

  class Root < Thor

    desc '[OPTIONS]', 'Replicate the Java Buildpack Dependency Cache to the local filesystem'

    option :base_uri,
           desc:     'The base uri to use inside index.yml files',
           aliases:  '-b',
           required: false

    option :host_name,
           desc:     'The host name to use inside index.yml files',
           aliases:  '-h',
           required: false

    option :number_of_downloads,
           desc:    'The number of parallel downloads',
           aliases: '-n',
           type:    :numeric,
           default: 50

    option :output,
           desc:     'The output location for the replicated cache',
           aliases:  '-o',
           required: true

    def initialize(args = [], local_options = {}, config = {})
      super(args, local_options, config)

      @pool          = Thread.pool(options[:number_of_downloads])
      @index_updater = IndexUpdater.new(options[:base_uri], options[:host_name])
    end

    def replicate
      with_timing do
        futures = ObjectCollection.new.map { |object| @pool.future { process object } }
        futures.each(&:~)
        @pool.shutdown
      end
    rescue SignalException, StandardError
      @pool.shutdown!
      abort "\nIncomplete\n"
    end

    private

    default_task :replicate

    def process(object)
      replicated_file = ReplicatedFile.new options[:output], object.key

      with_cleanup(object) do
        object.replicate replicated_file
        @index_updater.update replicated_file
      end
    end

    def with_cleanup(object)
      yield
    rescue => e
      $stderr.print "FAILURE (#{object.key}): #{e}\n"
      raise e
    end

    def with_timing
      download_start_time = Time.now
      yield
      print "\nComplete (#{(Time.now - download_start_time).duration})\n"
    end

  end

end
