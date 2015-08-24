require Rails.root.join('app', 'controllers', 'passwords_controller')

module PerforceSwarm
  module PasswordsControllerExtension
    def update
      token = resource_params[:reset_password_token]
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token)
      if User.where(reset_password_token: reset_password_token).first.id == 1
        p4 = PerforceSwarm::P4Connection.new
        message = p4.change_root_password(params[:user][:password])
        redirect_to :back, alert: message && return if message
      end
      super
    end
  end
end

class PasswordsController < Devise::PasswordsController
  prepend PerforceSwarm::PasswordsControllerExtension
end
