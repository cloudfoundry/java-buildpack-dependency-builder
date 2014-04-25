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
require 'build/dependency/openjdk/openjdk_resources'
require 'build/dependency/openjdk/platform_details'

module Build
  module Dependency

    class CACertsBuilder
      include OpenJDKResources
      include PlatformDetails

      def build
        unless File.exist? cacerts
          puts 'Creating cacerts...'

          Dir.mktmpdir do |root|
            splitter = if macosx?
                         "split -p '-----BEGIN CERTIFICATE-----' - #{root}/"
                       else
                         "csplit -s -f #{root}/ - '/-----BEGIN CERTIFICATE-----/' {*}"
                       end

            system <<-EOF
curl -s #{CACERTS_URI} | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{ print $0; }' | #{splitter}

for I in $(find #{root} -type f) ; do
  keytool -importcert -noprompt -keystore #{cacerts} -storepass changeit -file $I -alias $(basename $I)
done
            EOF
          end
        end
      end

      def cacerts
        CACERTS_FILE
      end

      CACERTS_FILE = File.join(VENDOR_DIR, 'cacerts').freeze

      CACERTS_URI = 'http://curl.haxx.se/ca/cacert.pem'.freeze

      private_constant :CACERTS_FILE, :CACERTS_URI

    end

  end
end
