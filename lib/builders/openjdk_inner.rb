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
require 'English'
require 'tmpdir'

module Builders

  class OpenJDKInner < Base

    def initialize(options)
      super 'openjdk', 'tar.gz', options
    end

    protected

    def base_path
      architecture = `uname -m`.strip
      "openjdk/#{codename}/#{architecture}"
    end

    def codename
      if IS_CENTOS
        File.open('/etc/redhat-release', 'r') { |f| "centos#{f.read.match(/CentOS release (\d)/)[1]}" }
      elsif IS_MACOSX
        'mountainlion'
      elsif IS_UBUNTU
        `lsb_release -cs`.strip
      else
        fail 'Unable to determine codename'
      end
    end

    def download(file, version)
      version_details = version_specific(@version)
      clone version_details[:repository], version_details[:source_location]
      checkout_tag version_details[:source_location], @tag
      create_cacerts
      instance_exec(file, @version, @build_number, version_details[:source_location], &version_details[:builder])
    end

    def version_specific(version)
      if version =~ /^1.6/
        VERSION_SPECIFIC[:six]
      elsif version =~ /^1.7/
        VERSION_SPECIFIC[:seven]
      elsif version =~ /^1.8/
        VERSION_SPECIFIC[:eight]
      else
        fail "Unable to process version '#{version}'"
      end
    end

    private

    BOOSTRAP_JDK_URI = 'http://download.oracle.com/otn-pub/java/jdk/7u21-b11/jdk-7u21-linux-x64.tar.gz'

    CACERTS_URI = 'http://curl.haxx.se/ca/cacert.pem'

    IS_CENTOS = File.exist? '/etc/redhat-release'

    IS_MACOSX = `uname -s` =~ /Darwin/

    IS_UBUNTU = !`which lsb_release 2> /dev/null`.empty?

    LEAF_PATCH = File.expand_path('../openjdk/6_and_7/leaf.diff', __FILE__)

    SEL_PATCH = File.expand_path('../openjdk/6_and_7/sel.diff', __FILE__)

    SOUND_PATCH = File.expand_path('../openjdk/6_and_7/asound.diff', __FILE__)

    STAT64_PATCH = File.expand_path('../openjdk/6_and_7/stat64.diff', __FILE__)

    VENDOR_DIRECTORY = File.expand_path('../../../vendor/openjdk', __FILE__)

    BOOSTRAP_JDK_ROOT = File.join VENDOR_DIRECTORY, 'bootstrap-jdk'

    CACERTS_FILE = File.join VENDOR_DIRECTORY, 'cacerts'

    CACERTS_STAGING_DIRECTORY = File.join VENDOR_DIRECTORY, 'cacerts-staging'

    SOURCE_ROOT = File.join VENDOR_DIRECTORY, 'source'

    VERSION_SPECIFIC = {
      six:   {
        repository:      'http://hg.openjdk.java.net/jdk6/jdk6',
        source_location: File.join(SOURCE_ROOT, 'jdk6'),
        builder:         ->(file, version, build_number, source_location) { build_6_and_7(file, version, build_number, source_location) }
      },
      seven: {
        repository:      'http://hg.openjdk.java.net/jdk7u/jdk7u',
        source_location: File.join(SOURCE_ROOT, 'jdk7u'),
        builder:         ->(file, version, build_number, source_location) { build_6_and_7(file, version, build_number, source_location) }
      },
      eight: {
        repository:      'http://hg.openjdk.java.net/jdk8/jdk8',
        source_location: File.join(SOURCE_ROOT, 'jdk8'),
        builder:         ->(file, version, build_number, source_location) { build_8(file, version, build_number, source_location) }
      }
    }

    def alt_bootdir
      if IS_CENTOS
        '/usr/lib/jvm/java-1.6.0-openjdk.x86_64'
      elsif IS_UBUNTU
        '/usr/lib/jvm/java-6-openjdk'
      elsif IS_MACOSX
        ENV['JAVA6_HOME']
      else
        fail 'Unable to determine ALT_BOOTDIR'
      end
    end

    def build_dir_6_and_7
      IS_MACOSX ? 'macosx-x86_64' : 'linux-amd64'
    end

    def build_dir_8
      IS_MACOSX ? 'macosx-x86_64-normal-server-release' : 'linux-x86_64-normal-server-release'
    end

    def cpu_count
      if IS_CENTOS
        `nproc`.strip
      else
        `sysctl -n hw.ncpu`.strip
      end
    end

    def build_6_and_7(file, version, build_number, source_location)
      puts "Building #{@name} #{version}..."
      Dir.chdir source_location do
        system <<-EOF
patch -N -p0 -i #{LEAF_PATCH}
patch -N -p0 -i #{SEL_PATCH}
patch -N -p0 -i #{SOUND_PATCH}
patch -N -p0 -i #{STAT64_PATCH}
unset JAVA_HOME
export LANG=C ALT_BOOTDIR=#{alt_bootdir} ALT_CACERTS_FILE=#{CACERTS_FILE} PATH=/usr/bin:$PATH
make MILESTONE=fcs JDK_VERSION=#{version} BUILD_NUMBER=#{build_number} ALLOW_DOWNLOADS=true NO_DOCS=true PARALLEL_COMPILE_JOBS=#{cpu_count} HOTSPOT_BUILD_JOBS=#{cpu_count}

tar czvf #{file.path} --exclude=*.debuginfo --exclude=*.diz -C build/#{build_dir_6_and_7}/j2re-image .
        EOF
      end

      abort unless $CHILD_STATUS == 0
    end

    def build_8(file, version, build_number, source_location)
      unless File.exist?(BOOSTRAP_JDK_ROOT || IS_MACOSX)
        puts 'Downloading bootstrap JDK...'
        system "mkdir #{BOOSTRAP_JDK_ROOT}"
        system "curl -Ls --cookie 'gpw_e24=http%3A%2F%2Fwww.oracle.com%2F' #{BOOSTRAP_JDK_URI} | tar xz --strip 1 -C #{BOOSTRAP_JDK_ROOT}"
      end

      puts "Building #{@name} #{version}..."
      Dir.chdir source_location do
        system <<-EOF
export LANG=C PATH=#{BOOSTRAP_JDK_ROOT}/bin:$PATH
bash ./configure --with-cacerts-file=#{CACERTS_FILE}
make MILESTONE= JDK_VERSION=#{version} JDK_BUILD_NUMBER=#{build_number} ALLOW_DOWNLOADS=true GENERATE_DOCS=false PARALLEL_COMPILE_JOBS=#{cpu_count} HOTSPOT_BUILD_JOBS=#{cpu_count} all

tar czvf #{file.path} --exclude=*.debuginfo --exclude=*.diz -C build/#{build_dir_8}/images/j2re-image .
        EOF
      end

      abort unless $CHILD_STATUS == 0
    end

    def create_cacerts
      unless File.exist? CACERTS_FILE
        puts 'Creating cacerts...'

        Dir.mktmpdir do |root|
          splitter = IS_MACOSX ? "split  -p '-----BEGIN CERTIFICATE-----' - #{root}/" : "csplit -s -f #{root}/ - '/-----BEGIN CERTIFICATE-----/' {*}"

          system <<-EOF
curl -s #{CACERTS_URI} | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{ print $0; }' | #{splitter}

for I in $(find #{root} -type f) ; do
  keytool -importcert -noprompt -keystore #{CACERTS_FILE} -storepass changeit -file $I -alias $(basename $I)
done
          EOF
        end

      end
    end

    def checkout_tag(source_location, tag)
      puts "Checking out #{tag}..."
      Dir.chdir source_location do
        system 'make/scripts/hgforest.sh purge --all'
        system "make/scripts/hgforest.sh checkout #{tag}"
      end

      abort unless $CHILD_STATUS == 0
    end

    def clone(repository, source_location)
      hgrc = File.join ENV['HOME'], '/.hgrc'
      File.open(hgrc, 'w') { |f| f.write "[extensions]\npurge =\n" } unless File.exist? hgrc

      if File.exist? source_location
        puts "Updating #{source_location} from #{repository}..."
        Dir.chdir(source_location) do
          system 'hg purge --all'
          system 'hg update'
        end
      else
        puts "Cloning #{repository} to #{source_location}..."

        FileUtils.mkdir_p source_location
        system "hg clone #{repository} #{source_location}"
      end

      Dir.chdir source_location do
        system 'chmod +x get_source.sh make/scripts/hgforest.sh'
        system './get_source.sh'
      end

      abort unless $CHILD_STATUS == 0
    end

  end

end
