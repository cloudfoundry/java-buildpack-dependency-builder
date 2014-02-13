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
require 'builders/util/mmmq_normalizer'
require 'net/http'

module Builders
  class AppDynamics < Base
    include Builders::MMMQNormalizer

    def initialize(options)
      super 'app-dynamics', 'zip', options
    end

    protected

    def download(file, version)
      uri = URI(instance_exec(version, &version_specific(version)))

      print "Downloading #{@name} #{version} from #{uri}"

      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new('https://login.appdynamics.com/sso/login/')
        request.set_form_data('username' => @username, 'password' => @password)
        response = http.request(request).response
        cookie = response.get_fields('set-cookie').find { |h| h =~ /sso-sessionid/ }.split('; ').first

        request = Net::HTTP::Get.new(uri.path)
        request['Cookie'] = cookie

        pump file, http, request
      end

      file.close
    end

    def version_specific(version)
      if @latest
        ->(v) { 'http://download.appdynamics.com/onpremise/public/latest/AppServerAgent.zip' }
      else
        ->(v) { "http://download.appdynamics.com/onpremise/public/archives/#{v}/AppServerAgent.zip" }
      end
    end
  end
end
