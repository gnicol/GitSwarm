require 'rubygems'
require 'sidekiq'
require 'sidetiq'
require Rails.root.join('lib', 'gitlab', 'current_settings')

module PerforceSwarm
  class VersionCacheWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable
    include Gitlab::CurrentSettings

    # randomize when the worker runs to be on a random minute of every day
    recurrence { daily.hour_of_day(rand(24)).minute_of_hour(rand(60)) }

    def perform
      # we only run the automated check if the admin has explicitly enabled it
      return unless current_application_settings.version_check_enabled

      # download versions file with forced download and cache
      ::VersionCheck.versions(false)
    end
  end
end
