require Rails.root.join('app', 'controllers', 'profiles', 'passwords_controller')

module PerforceSwarm
  module PasswordsControllerExtension
    def update
      if @user.update_attributes(params[:password]) && @user.valid_password?(user_params[:current_password]) && @user.id == 1 &&
          params[:user][:password] == params[:user][:password_confirmation]
        p4 = PerforceSwarm::P4Connection.new
        message = p4.change_root_password(params[:user][:password])
        render 'edit' && return if message
      end
      super
    end
  end
end

class Profiles::PasswordsController < Profiles::ApplicationController
  prepend PerforceSwarm::PasswordsControllerExtension
end
