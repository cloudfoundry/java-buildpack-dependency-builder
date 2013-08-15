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

require 'builders/auto_reconfiguration'
require 'builders/groovy'
require 'builders/mysql_jdbc'
require 'builders/openjdk'
require 'builders/new_relic'
require 'builders/play_jpa_plugin'
require 'builders/postgresql_jdbc'
require 'builders/spring_boot_cli'
require 'builders/tomcat'
require 'thor'

module Builders

  class Root < Thor

    class_option :access_key, {
      desc: 'The AWS access key to use',
      aliases: '-a',
      required: true
    }

    class_option :bucket, {
      desc: 'The name of the AWS S3 bucket to upload to',
      aliases: '-b',
      required: true
    }

    class_option :secret_access_key, {
      desc: 'The AWS secret access key to use',
      aliases: '-s',
      required: true
    }

    class_option :version, {
      desc: 'The version to publish',
      aliases: '-v',
      required: true
    }

    desc 'auto-reconfiguration [OPTIONS]', 'Publish a version of Auto Reconfiguration'
    def auto_reconfiguration
      AutoReconfiguration.new(options).publish
    end

    desc 'groovy [OPTIONS]', 'Publish a version of Groovy'
    def groovy
      Groovy.new(options).publish
    end

    desc 'mysql-jdbc [OPTIONS]', 'Publish a version of MySQL JDBC'
    def mysql_jdbc
      MySQLJDBC.new(options).publish
    end

    desc 'openjdk [OPTIONS]', 'Publish a version of OpenJDK'
    option :key_name, {
      desc: 'The name of the EC2 keypar to use when creating the instance. This is optional and defaults to Cloud Foundry.',
      aliases: '-k',
      default: 'Cloud Foundry'
    }
    option :build_number, {
      desc: 'The builder number of OpenJDK to create',
      aliases: '-n',
      required: true
    }
    option :tag, {
      desc: 'The repository tag to build from',
      aliases: '-t',
      required: true
    }
    def openjdk
      OpenJDK.new(options).publish
    end

    desc 'new-relic [OPTIONS]', 'Publish a version of New Relic'
    def new_relic
      NewRelic.new(options).publish
    end

    desc 'play-jpa-plugin [OPTIONS]', 'Publish a version of the Play JPA Plugin'
    def play_jpa_plugin
      PlayJPAPlugin.new(options).publish
    end

    desc 'postgresql-jdbc [OPTIONS]', 'Publish a version of PostgreSQL JDBC'
    def postgresql_jdbc
      PostgreSQLJDBC.new(options).publish
    end

    desc 'spring-boot-cli [OPTIONS]', 'Publish a version of Spring Boot'
    def spring_boot_cli
      SpringBootCLI.new(options).publish
    end

    desc 'tomcat [OPTIONS]', 'Publish a version of Tomcat'
    def tomcat
      Tomcat.new(options).publish
    end

  end

end
