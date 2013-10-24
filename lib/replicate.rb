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

require 'aws-sdk'
require 'fileutils'
require 'pathname'
require 'thor'
require 'thread/pool'

class Replicate < Thor

  desc '[OPTIONS]', 'Replicate the Java Buildpack Dependency Cache to the local filesystem'
  option :access_key, {
    desc: 'The AWS access key to use',
    aliases: '-a',
    required: true
  }
  option :number_of_downloads, {
    desc: 'The number of parallel downloads',
    aliases: '-n',
    type: :numeric,
    default: 50
  }
  option :output, {
      desc: 'The outuput location for the replicated cache',
      aliases: '-o',
      required: true
    }
  option :secret_access_key, {
    desc: 'The AWS secret access key to use',
    aliases: '-s',
    required: true
  }
  def replicate
    download_start_time = Time.now

    init_output

    pool = Thread.pool(options[:number_of_downloads])
    s3.buckets[BUCKET].objects
      .select { |object| object.key !~ /\/$/ }
      .each { |object| process object, pool}
    pool.shutdown

    print "\nComplete (#{(Time.now - download_start_time).duration})\n"
  end

  private

  BUCKET = 'download.pivotal.io'.freeze

  default_task :replicate

  def process(object, pool)
    pool.process do
      path = Pathname.new(options[:output]) + object.key

      begin
        download_start_time = Time.now

        FileUtils.mkdir_p path.dirname
        File.open(path, 'wb') { |file| object.read { |chunk| file.write(chunk) } }
        File.utime(object.last_modified, object.last_modified, path)

        print "#{object.key} (#{object.content_length.ibi} => #{(Time.now - download_start_time).duration})\n"
      rescue => e
        FileUtils.rm_rf path
        print "FAILURE (#{object.key}): #{e}\n"
      end
    end
  end

  def init_output
    FileUtils.rm_rf options[:output]
    FileUtils.mkdir_p options[:output]
  end

  def s3
    AWS::S3.new(
      access_key_id: options[:access_key],
      secret_access_key: options[:secret_access_key]
    )
  end

end

class Numeric

  def duration
    remainder = self

    hours = (remainder / HOUR).to_int
    remainder -= HOUR * hours

    minutes = (remainder / MINUTE).to_int
    remainder -= MINUTE * minutes

    return "#{hours}h #{minutes}m" if hours > 0

    seconds = (remainder / SECOND).to_int
    remainder -= SECOND * seconds

    return "#{minutes}m #{seconds}s" if minutes > 0

    tenths = (remainder / TENTH).to_int
    "#{seconds}.#{tenths}s"
  end

  def ibi
    if self > GIBI
      "%.1f GiB" % (self / GIBI)
    elsif self > MIBI
      "%.1f MiB" % (self / MIBI)
    elsif self > KIBI
      "%.1f KiB" % (self / KIBI)
    else
      "#{self} B"
    end
  end

  private

  MILLISECOND = 0.001.freeze

  TENTH = (100 * MILLISECOND).freeze

  SECOND = (10 * TENTH).freeze

  MINUTE = (60 * SECOND).freeze

  HOUR = (60 * MINUTE).freeze

  BYTE = 1.freeze

  KIBI = (1024 * BYTE).freeze

  MIBI = (1024 * KIBI).freeze

  GIBI = (1024 * MIBI).freeze

end

