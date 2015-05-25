require 'rubygems'
require 'sidekiq'
require 'sidetiq'
require Rails.root.join('lib', 'gitlab', 'current_settings')

module PerforceSwarm
  class AsyncVersionCheck
    include Sidekiq::Worker
    include Sidetiq::Schedulable
    include Gitlab::CurrentSettings
    include PerforceSwarm::VersionCheck

    # @TODO: Change this to daily or something more sensible before it goes out
    recurrence { minutely }

    def perform
      # we only run the automated check if the admin has explicitly enabled it
      return unless current_application_settings.version_check_enabled

      # download versions file (force download) and cache it if we get a valid response
      versions = populate_versions(false)
      Rails.cache.write(VERSIONS_CACHE_KEY, versions) if versions
    end
  end
end
