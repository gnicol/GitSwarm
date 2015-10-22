require Rails.root.join('app', 'mailers', 'base_mailer')

module PerforceSwarm
  module BaseMailerExtension
    # The default email address to send emails from
    def default_sender_address
      address = Mail::Address.new(Gitlab.config.gitlab.email_from)
      address.display_name = 'GitSwarm'
      address
    end
  end
end

class BaseMailer < ActionMailer::Base
  prepend PerforceSwarm::BaseMailerExtension
end
