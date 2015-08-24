require Rails.root.join('app', 'controllers', 'admin', 'users_controller')

module PerforceSwarm
  module UsersControllerExtension
    def update
      if params[:user][:username] == 'root' && !params[:user][:password_confirmation].empty? &&
         params[:user][:password] == params[:user][:password_confirmation]
        p4 = PerforceSwarm::P4Connection.new
        message = p4.change_root_password(params[:user][:password])
        if message
          flash.now[:alert] = message
          render 'edit'
          return
        end
      end
      super
    end
  end
end

class Admin::UsersController < Admin::ApplicationController
  prepend PerforceSwarm::UsersControllerExtension
end
