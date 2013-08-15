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

require 'builders/base'

module Builders

  class OpenJDK

    def initialize(options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }

      @ec2 = AWS::EC2.new(
        access_key_id: @access_key,
        secret_access_key: @secret_access_key,
        region: 'eu-west-1'
      )
    end

    def publish
      print 'Starting instance... '
      instance = @ec2.instances.create(
        image_id: 'ami-881d13fc',
        instance_type: 'm1.small',
        security_groups: 'default',
        key_name: @key_name,
        user_data: build_multipart(version_specific(@version))
      )

      instance.tags['Name'] = "openjdk-#{@version}-#{@build_number}"
      puts 'OK'
    end

    private

    VERSION_SPECIFIC = {
      six: {
        repository: 'http://hg.openjdk.java.net/jdk6/jdk6',
        cloud_config: 'lib/builders/openjdk/cloud-config-6and7.yml',
        remote_build: 'lib/builders/openjdk/remote-build-6and7.rb'
      },
      seven: {
        repository: 'http://hg.openjdk.java.net/jdk7u/jdk7u',
        cloud_config: 'lib/builders/openjdk/cloud-config-6and7.yml',
        remote_build: 'lib/builders/openjdk/remote-build-6and7.rb'
      },
      eight: {
        repository: 'http://hg.openjdk.java.net/jdk8/jdk8',
        cloud_config: 'lib/builders/openjdk/cloud-config-8.yml',
        remote_build: 'lib/builders/openjdk/remote-build-8.rb'
      }
    }

    def build_multipart(version_specific)
      raw_multipart(version_specific)
      .gsub(/@@ACCESS_KEY@@/, @access_key)
      .gsub(/@@BUCKET@@/, @bucket)
      .gsub(/@@BUILD_NUMBER@@/, @build_number)
      .gsub(/@@VERSION@@/, @version)
      .gsub(/@@REPOSITORY@@/, version_specific[:repository])
      .gsub(/@@SECRET_ACCESS_KEY@@/, @secret_access_key)
      .gsub(/@@TAG@@/, @tag)
    end

    def raw_multipart(version_specific)
      <<-EOF
      Content-Type: multipart/mixed; boundary="===============7910318705544163955=="
      MIME-Version: 1.0

      --===============7910318705544163955==
        MIME-Version: 1.0
      Content-Type: text/cloud-config; charset="UTF-8"
      Content-Disposition: attachment

      #{File.read(version_specific[:cloud_config])}
      --===============7910318705544163955==
        MIME-Version: 1.0
      Content-Type: text/x-shellscript; charset="UTF-8"
      Content-Disposition: attachment

      #!/usr/bin/env bash
      gem install aws-sdk --no-ri --no-rdoc

      --===============7910318705544163955==
        MIME-Version: 1.0
      Content-Type: text/x-shellscript; charset="UTF-8"
      Content-Disposition: attachment

      #{File.read(version_specific[:remote_build])}
      --===============7910318705544163955==--
        EOF
    end

    def version_specific(version)
      if version =~ /^1.6/
        VERSION_SPECIFIC[:six]
      elsif version =~ /^1.7/
        VERSION_SPECIFIC[:seven]
      elsif version =~ /^1.8/
        VERSION_SPECIFIC[:eight]
      else
        raise "Unable to process version '#{version}'"
      end
    end

  end

end
