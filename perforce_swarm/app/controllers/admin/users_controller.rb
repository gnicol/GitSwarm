require Rails.root.join('app', 'controllers', 'admin', 'users_controller')

module PerforceSwarm
  module UsersControllerExtension
    def update
      if params[:user][:username] == 'root' && params[:user][:password].present?
        new_root_password = params[:user][:password]
        PerforceSwarm::P4DManager.update_p4d_root_password(new_root_password)
      end
      super
    end
  end
end

class Admin::UsersController < Admin::ApplicationController
  prepend PerforceSwarm::UsersControllerExtension
end
