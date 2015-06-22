require Rails.root.join('app', 'controllers', 'admin', 'users_controller')

module PerforceSwarm
  module UsersControllerExtension
    def update
      if params[:user][:username] == 'root' && params[:user][:password].present?
        new_root_password = params[:user][:password]
        logger.info("Send new root password to p4d. #{new_root_password}")
      end
      super
    end
  end
end

class Admin::UsersController < Admin::ApplicationController
  prepend PerforceSwarm::UsersControllerExtension
end
