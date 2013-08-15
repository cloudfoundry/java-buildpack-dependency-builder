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

module Builders

  class ProgressIndicator

    def initialize(total)
      @current = 0
      @increment = total / 10
      @limit = @increment
    end

    def increment(chunk)
      @current += chunk

      while @current >= @limit
        print '.'
        @limit += @increment
      end
    end

    def finish
      puts ''
    end

  end

end
