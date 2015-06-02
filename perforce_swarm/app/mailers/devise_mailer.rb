require Rails.root.join('app', 'mailers', 'devise_mailer')

class DeviseMailer < Devise::Mailer
  default from: "GitSwarm <#{Gitlab.config.gitlab.email_from}>"
end
