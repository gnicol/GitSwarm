require Rails.root.join('lib', 'version_check')
require 'json'
require 'net/https'
require 'uri'

module PerforceSwarm
  module VersionCheckSelf
    VERSIONS_CACHE_KEY ||= 'perforce_swarm:versions'

    def version_uri
      "https://updates.perforce.com/static/GitSwarm/GitSwarm#{PerforceSwarm.ee? ? '-ee' : ''}.json"
    end

    def versions(use_cached = true)
      if use_cached
        @versions = Rails.cache.fetch(VERSIONS_CACHE_KEY) unless @versions
        return @versions if @versions
      end

      # @todo: there is the potential for a cache stampede here if multiple http requests get to here at the same point.
      # It is unlikely, since the TTL on the cache is 25 hours, and the automated refresh happens every 24 hours, but it
      # is possible. If this happens, we may want to use local file locks to prevent it.
      begin
        uri               = URI.parse(version_uri + '?product=' +
                                      URI.encode('GitSwarm/' + PerforceSwarm::VERSION + '/' + Gitlab::REVISION) +
                                      '&platform=' + URI.encode(platform))
        http              = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl      = (uri.scheme == 'https')
        http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
        http.open_timeout = 5
        http.read_timeout = 5

        response  = http.request(Net::HTTP::Get.new(uri.request_uri))
        @versions = JSON.parse(response.body)
        @versions = @versions['versions']
      rescue
        @versions = {}
      end
      Rails.cache.write(VERSIONS_CACHE_KEY, @versions, expires_in: 25.hours)
      @versions
    end

    # determines which platform and major version we are under:
    #  centos6x86_64, centos7x86_64, ubuntu12x86_64, ubuntu14x86_64, noarch
    # returns 'noarch' if platform could not be identified, or there was an error trying to determine it
    def platform
      return @platform if @platform

      # if we have a readable platform file, use it
      platform_file = File.join(Rails.root, '.platform')
      if File.readable?(platform_file)
        @platform = File.read(platform_file).strip
        return @platform
      end

      # we don't have an explicit file, make a best guess for the platform
      @platform = 'noarch'
      if File.exist?('/etc/redhat-release')
        # RedHat/CentOS
        /CentOS release (?<major>\d+)\.(\d+) / =~ File.read('/etc/redhat-release')
        @platform = major.nil? ? 'noarch' : "centos#{major}x86_64"
      elsif File.executable?('/usr/bin/lsb_release')
        # run lsb_release -a to get the release version
        /Release:\s+(?<major>\d+)\.(\d+)/ =~ `/usr/bin/lsb_release -a`
        @platform = major.nil? ? 'noarch' : "ubuntu#{major}x86_64"
      end
      @platform
    end

    # returns a list of versions applicable to the current platform
    # we anticipate the version file may eventually drop platform details and just use noarch
    # if we don't see an entry for our platform, assume that happened and fallback to noarch
    def applicable_versions
      # remove any versions that don't match our platform
      our_versions = select_by_platform(platform)
      if our_versions.empty?
        # we didn't have any OS-specific matches, so use 'noarch'
        our_versions = select_by_platform('noarch')
      end
      our_versions
    end

    def select_by_platform(platform)
      our_versions = versions.clone
      our_versions.delete_if { |version| version['platform'] != platform }
    end

    def outdated?
      update_details != false && !update_details.nil?
    end

    def latest
      details('version', PerforceSwarm::VERSION)
    end

    def critical?
      details('critical')
    end

    def more_info
      base_url = details('more_info')
      return base_url unless base_url
      base_url += base_url.include?('?') ? '&' : '?'
      base_url + 'version='   + URI.encode(PerforceSwarm::VERSION) +
        '&revision=' + URI.encode(Gitlab::REVISION) +
        'platform=' + URI.encode(platform)
    end

    def details(key, default = false)
      details = update_details
      return details[key] if details
      default
      rescue StandardError => e
        Rails.logger.warn("Error during check for update: #{e.class} #{e.message}") if Rails.logger
        return default
    end

    def parse_version(version)
      version += '-1' unless version.match(/\-.+$/)
      Gem::Version.new(version)
    end

    def valid_version?(version)
      !version.strip.empty? && Gem::Version.correct?(version)
    end

    # returns details on the newer version or nil if you're up to date
    def update_details
      # download the versioning information, and remove any non-applicable versions
      applicable = applicable_versions
      return nil if applicable.empty?

      # compare our current version to the applicable ones and determine if we are current, out of date, or critical
      details     = nil
      critical    = false
      our_version = parse_version(PerforceSwarm::VERSION)
      applicable.each do |version|
        # ensure we have a valid, non-empty version, or skip this one
        next unless version['version'] && valid_version?(version['version'])
        current_version = parse_version(version['version'])
        next if our_version >= current_version

        # if any newer version is critical, the update is critical
        critical ||= version['critical']

        # if this version is the newest we've seen; its the winner for the moment
        details = version if !details || current_version > parse_version(details['version'])
      end
      details['critical'] = critical if details
      details
    rescue
      return nil
    end
  end
end

class VersionCheck
  class << self
    prepend PerforceSwarm::VersionCheckSelf
  end
end
