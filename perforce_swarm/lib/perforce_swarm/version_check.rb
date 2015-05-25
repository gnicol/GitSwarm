require Rails.root.join('lib', 'version_check')
require 'json'
require 'net/https'
require 'uri'

module PerforceSwarm
  module VersionCheck
    VERSION_UNKNOWN = 'unknown'
    VERSION_CURRENT = 'current'
    VERSION_NEEDS_UPDATE = 'needs_update'
    VERSION_CRITICAL = 'critical'

    attr_reader :versions, :platform

    def initialize
      @versions = {}
      @platform = 'noarch'
    end

    def populate_versions
      # @TODO: add logic to look for and use the cached version once SideTiq is integrated
      uri = URI.parse('https://updates.perforce.com/static/GitSwarm/GitSwarm.json?product=' +
                          PerforceSwarm::VERSION)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
      begin
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        @versions = JSON.parse(response.body)
        @versions = @versions['versions']
      rescue
        @versions = {}
      end
    end

    # guesses the current platform, and removes any non-matching results from the internal versions list
    def select_applicable_versions
      guess_platform
      # remove any versions that don't match our platform
      our_versions = select_by_platform(@platform)
      if our_versions.empty?
        # we didn't have any OS-specific matches, so use 'noarch'
        our_versions = select_by_platform('noarch')
      end
      @versions = our_versions
    end

    def select_by_platform(platform)
      our_versions = @versions.clone
      our_versions.delete_if { |version| version['platform'] != platform }
    end

    # determines which platform and major version we are under:
    #  centos6x86_64, centos7x86_64, ubuntu12x86_64, ubuntu14x86_64, noarch
    # returns 'noarch' if platform could not be identified, or there was an error trying to determine it
    def guess_platform
      @platform = 'noarch'

      # we only support x86_64 Linux
      return unless RUBY_PLATFORM == 'x86_64-linux'

      if File.exist?('/etc/redhat-release')
        # RedHat/CentOS
        /CentOS release (?<major>\d+)\.(?<minor>\d+) / =~ File.read('/etc/redhat-release')
        @platform = major.nil? ? 'noarch' : "centos#{major}x86_64"
      elsif File.exist?('/usr/bin/lsb_release') && File.executable?('/usr/bin/lsb_release')
        # run lsb_release -a to get the release version
        version = `/usr/bin/lsb_release -a`
        version.split("\n").each do |value|
          next unless value.match(/^Release:/)
          /Release:\s+(?<major>\d\d)\.(?<minor>\d\d)$/ =~ value
          @platform = major.nil? ? 'noarch' : "ubuntu#{major}x86_64"
        end
      end
    end

    def check_version
      /^(?<major>\d+)\.(?<minor>\d+)\-(?<build>.+)$/ =~ PerforceSwarm::VERSION
      return VERSION_UNKNOWN unless major && minor && build
      major = major.to_version
      minor = minor.to_version
      build = build.to_version

      # download the versioning information, and remove any non-applicable versions
      populate_versions
      select_applicable_versions
      return VERSION_UNKNOWN if @versions.empty?

      # compare our current version to the applicable ones and determine if we are current, out of date, or critical
      result = VERSION_CURRENT
      @versions.each do |version|
        version_major = version['major'].to_version
        version_minor = version['minor'].to_version
        version_build = version['build'].to_version
        # check if we're at or ahead
        next if major > version_major ||
                (major == version_major && minor > version_minor) ||
                (major == version_major && minor == version_minor && build >= version_build)
        # being a major version out of date, or missing a flagged update is always considered critical
        return VERSION_CRITICAL if major < version_major || version['critical']

        # we're just plain old out of date
        result = VERSION_NEEDS_UPDATE
      end
      result
    end
  end

  module ToVersion
    def to_version
      version = downcase
      return -2 if version == 'alpha'
      return -1 if version == 'beta'
      to_i
    end
  end
end

class String
  prepend PerforceSwarm::ToVersion
end

class VersionCheck
  prepend PerforceSwarm::VersionCheck
end
