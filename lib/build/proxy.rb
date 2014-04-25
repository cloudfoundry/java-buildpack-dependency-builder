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

require 'build'
require 'net/http'

module Build
  module Proxy

    def proxy(uri)
      proxy_uri = if secure?(uri)
                    URI.parse(ENV['https_proxy'] || ENV['HTTPS_PROXY'] || '')
                  else
                    URI.parse(ENV['http_proxy'] || ENV['HTTP_PROXY'] || '')
                  end

      Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
    end

    def secure?(uri)
      uri.scheme == 'https'
    end

  end
end
