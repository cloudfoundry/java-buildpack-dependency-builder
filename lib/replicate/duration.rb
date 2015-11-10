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

class Numeric
  def duration
    remainder = self

    hours     = (remainder / HOUR).to_int
    remainder -= HOUR * hours

    minutes   = (remainder / MINUTE).to_int
    remainder -= MINUTE * minutes

    return "#{hours}h #{minutes}m" if hours > 0

    seconds   = (remainder / SECOND).to_int
    remainder -= SECOND * seconds

    return "#{minutes}m #{seconds}s" if minutes > 0

    tenths = (remainder / TENTH).to_int
    "#{seconds}.#{tenths}s"
  end

  MILLISECOND = 0.001

  TENTH = (100 * MILLISECOND).freeze

  SECOND = (10 * TENTH).freeze

  MINUTE = (60 * SECOND).freeze

  HOUR = (60 * MINUTE).freeze
end
