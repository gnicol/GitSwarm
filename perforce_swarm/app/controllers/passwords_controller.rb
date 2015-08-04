require Rails.root.join('app', 'controllers', 'passwords_controller')

module PerforceSwarm
  module PasswordsControllerExtension
    def update
      token = resource_params[:reset_password_token]
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token)
      if User.where(reset_password_token: reset_password_token).first.id == 1
        new_root_password = resource_params[:password]
        PerforceSwarm::P4DManager.update_p4d_root_password(new_root_password)
      end
      super
    end
  end
end

class PasswordsController < Devise::PasswordsController
  prepend PerforceSwarm::PasswordsControllerExtension
end
