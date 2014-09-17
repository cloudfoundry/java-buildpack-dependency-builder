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

require 'build/dependency'
require 'build/dependency/base'
require 'build/mmmq_normalizer'
require 'build/proxy'
require 'net/http'
require 'net/https'

module Build
  module Dependency

    class AppDynamics < Base
      include Build::MMMQNormalizer
      include Build::Proxy

      def initialize(options)
        super 'app-dynamics', 'zip', options

        @username = @configuration[:app_dynamics_username]
        @password = @configuration[:app_dynamics_password]
      end

      protected

      def headers
        { 'Cookie' => cookie }
      end

      def version_specific(version)
        if @latest
          ->(_v) { 'https://download.appdynamics.com/onpremise/public/latest/AppServerAgent.zip' }
        elsif version =~ /^[\d\.]+$/
          ->(v) { "https://download.appdynamics.com/onpremise/public/archives/#{v}/AppServerAgent-#{v}.zip" }
        else
          fail "Unable to process version '#{version}'"
        end
      end

      private

      LOGIN_URI = URI('https://login.appdynamics.com/sso/login/').freeze

      private_constant :LOGIN_URI

      def cookie
        proxy(LOGIN_URI).start(LOGIN_URI.host, LOGIN_URI.port, nil, nil, use_ssl: true) do |http|
          request = Net::HTTP::Post.new(LOGIN_URI.path)
          request.set_form_data('username' => @username, 'password' => @password)

          response = http.request(request).response
          response.get_fields('set-cookie').find { |h| h =~ /sso-sessionid/ }.split('; ').first
        end
      end
    end

  end
end
