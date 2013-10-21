#!/usr/bin/env ruby
# Encoding: utf-8
# Usage: script-name <blobstore-java-buildpack-cache-dir> <URL>
# where <blobstpre-java-bio;d[acl-cache-dir> points at the appropriate directory of cf-release, e.g.:
#   /some/path/cf-release/blobs/buildpack_cache/java-buildpack
# and <URL> is the URL of the item to be added to the blob store.

require 'uri'

cache = ARGV[0]
uri = ARGV[1]
key = URI.escape(uri, '/')
stash_file = File.join(cache, "#{key}.cached")

puts `wget #{uri} -O #{stash_file}`