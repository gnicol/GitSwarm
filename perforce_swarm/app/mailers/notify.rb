require Rails.root.join('app', 'mailers', 'notify')

module PerforceSwarm
  class NotifyMailerExtension
    # The default email address to send emails from
    def default_sender_address
      address = Mail::Address.new(Gitlab.config.gitlab.email_from)
      address.display_name = 'GitSwarm'
      address
    end
  end
end

class Notify < ActionMailer::Base
  prepend PerforceSwarm::NotifyMailerExtension
end
