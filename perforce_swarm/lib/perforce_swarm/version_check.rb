require Rails.root.join('lib', 'version_check')
require 'json'
require 'net/https'
require 'uri'

module PerforceSwarm
  module VersionCheck
    VERSION_UNKNOWN      ||= 'unknown'
    VERSION_CURRENT      ||= 'current'
    VERSION_NEEDS_UPDATE ||= 'needs_update'
    VERSION_CRITICAL     ||= 'critical'

    VERSIONS_URI         ||= 'https://updates.perforce.com/static/GitSwarm/GitSwarm.json?product='
    VERSIONS_CACHE_KEY   ||= 'perforce_swarm:versions'

    attr_reader :versions, :platform, :latest, :more_info

    def initialize
      @versions  = {}
      @platform  = nil
      @latest    = parse_version(PerforceSwarm::VERSION)
      @more_info = ''
    end

    def parse_version(version)
      version += '-0' unless version.match(/\-.+$/)
      Gem::Version.new(version)
    end

    # loads the cached versions file if it has been cached
    # returns true if the cached version was used, false otherwise
    def load_cached
      return false unless Rails.cache.exist?(VERSIONS_CACHE_KEY)
      @versions = Rails.cache.fetch(VERSIONS_CACHE_KEY)
      true
    end

    def populate_versions(use_cached = true)
      return if use_cached && load_cached
      uri              = URI.parse(VERSIONS_URI + URI.encode(PerforceSwarm::VERSION))
      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      begin
        response  = http.request(Net::HTTP::Get.new(uri.request_uri))
        @versions = JSON.parse(response.body)
        @versions = @versions['versions']
      rescue
        @versions = {}
      end
      @versions
    end

    # guesses the current platform, and removes any non-matching results from the internal versions list
    def select_applicable_versions
      # remove any versions that don't match our platform
      our_versions = select_by_platform(platform)
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
    def platform
      return @platform unless @platform.nil?

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
          /Release:\s+(?<major>\d+)\.(?<minor>\d+)/ =~ value
          @platform = major.nil? ? 'noarch' : "ubuntu#{major}x86_64"
        end
      end
      @platform
    end

    def check_version
      our_version = parse_version(PerforceSwarm::VERSION)

      # download the versioning information, and remove any non-applicable versions
      populate_versions
      select_applicable_versions
      return VERSION_UNKNOWN if @versions.empty?

      # compare our current version to the applicable ones and determine if we are current, out of date, or critical
      result  = VERSION_CURRENT
      @latest = our_version
      @versions.each do |version|
        current = parse_version(version['major'] + '.' + version['minor'] + '-' + version['build'])
        next if our_version >= current

        # find the maximum version (latest) and set the more_info field if there is one
        if @latest > current
          @latest    = current
          @more_info = version['more_info'] if version['more_info']
        end

        # missing a flagged update is always considered critical
        result = VERSION_CRITICAL if version['critical']

        # we're just plain old out of date, unless we've already found a prior critical one
        result = VERSION_NEEDS_UPDATE unless result == VERSION_CRITICAL
      end
      result
    end
  end
end

class VersionCheck
  prepend PerforceSwarm::VersionCheck
end
