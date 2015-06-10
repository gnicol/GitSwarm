require Rails.root.join('app', 'models', 'project_services', 'emails_on_push_service')

module PerforceSwarm
  module EmailsOnPushServiceExtension
    def fields
      super.each { |field|
        if field[:help]
          field[:help].gsub!(/GitLab/, 'GitSwarm')
        end
      }
    end
  end
end

class EmailsOnPushService < Service
  prepend PerforceSwarm::EmailsOnPushServiceExtension
end
