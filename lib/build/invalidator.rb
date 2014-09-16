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

require 'atomic'
require 'build'
require 'ruby-progressbar'
require 'securerandom'
require 'thread'

module Build

  class Invalidator

    def initialize(cloudfront, distribution_id, progress_stream = nil)
      @cloudfront      = cloudfront
      @distribution_id = distribution_id
      @progress_stream = progress_stream
    end

    def with_invalidation(object)
      exist_previously = object.exists?

      yield

      return unless exist_previously && @distribution_id

      complete = Atomic.new false
      [
        Thread.new { cloudfront object, complete },
        Thread.new { progress complete }
      ].each(&:join)
    end

    private

    PROGRESS_BAR_FORMAT = '%t |%B| %a'.freeze

    private_constant :PROGRESS_BAR_FORMAT

    def cloudfront(object, complete)
      @cloudfront.client.create_invalidation(distribution_id:    @distribution_id,
                                             invalidation_batch: {
                                               paths:            {
                                                 quantity: 1,
                                                 items:    ["/#{object.key}"]
                                               },
                                               caller_reference: SecureRandom.uuid })

      complete.value = true
    end

    def progress(complete)
      progress_bar = ProgressBar.create(format: PROGRESS_BAR_FORMAT,
                                        title:  'invalidation',
                                        total:  nil,
                                        output: @progress_stream)

      until complete.value
        progress_bar.increment
        sleep 0.5
      end

      progress_bar.total = progress_bar.progress # rubocop:disable UselessSetterCall
    end

  end

end
