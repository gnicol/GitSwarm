require Rails.root.join('app', 'controllers', 'profiles', 'passwords_controller')

module PerforceSwarm
  module PasswordsControllerExtension
    def update
      if @user.update_attributes(params[:password]) && @user.id == 1
        new_root_password = params[:password]
        PerforceSwarm::P4DManager.update_p4d_root_password(new_root_password)
      end
      super
    end
  end
end

class Profiles::PasswordsController < Profiles::ApplicationController
  prepend PerforceSwarm::PasswordsControllerExtension
end
