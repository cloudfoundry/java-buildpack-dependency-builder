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
  def ibi
    if self >= GIBI
      format('%.1f GiB', (self / GIBI))
    elsif self >= MIBI
      format('%.1f MiB', (self / MIBI))
    elsif self >= KIBI
      format('%.1f KiB', (self / KIBI))
    else
      "#{self} B"
    end
  end

  BYTE = 1.freeze

  KIBI = (1024 * BYTE).freeze

  MIBI = (1024 * KIBI).freeze

  GIBI = (1024 * MIBI).freeze
end
