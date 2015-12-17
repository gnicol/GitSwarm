require 'rubygems'
require 'sidekiq'
require Rails.root.join('lib', 'gitlab', 'current_settings')

module PerforceSwarm
  class VersionCacheWorker
    include Sidekiq::Worker
    include Gitlab::CurrentSettings

    def perform
      # we only run the automated check if the admin has explicitly enabled it
      return unless !Rails.env.test? && current_application_settings.version_check_enabled

      # download versions file with forced download and cache
      ::VersionCheck.versions(false)
    end
  end
end
