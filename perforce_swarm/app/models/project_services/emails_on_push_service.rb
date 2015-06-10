require Rails.root.join('app', 'models', 'project_services', 'emails_on_push_service')

module PerforceSwarm
  module EmailsOnPushServiceExtension
    def fields
      super.map do |fields|
        fields.dup.tap do |field|
          field[:help] = field[:help].gsub(/GitLab/, 'GitSwarm') if field[:help]
        end
      end
    end
  end
end

class EmailsOnPushService < Service
  prepend PerforceSwarm::EmailsOnPushServiceExtension
end
