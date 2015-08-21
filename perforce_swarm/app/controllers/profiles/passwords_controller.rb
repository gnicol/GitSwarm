require Rails.root.join('app', 'controllers', 'profiles', 'passwords_controller')

module PerforceSwarm
  module PasswordsControllerExtension
    def update
      if @user.update_attributes(params[:password]) && @user.id == 1
        @config = PerforceSwarm::Config.new
        p4 = PerforceSwarm::P4Connection.new(PerforceSwarm::GitFusion::ConfigEntry.new(@config))
        p4.login
        p4.input(params[:user][:password])
        begin
          p4.run('passwd', 'root')
        rescue P4Exception => ex
          message = ex.message.match(/\[Error\]: (?<message>.*)$/)
          flash.now[:alert] = message['message']
          render "edit" and return
        end
      end
      super
    end
  end
end

class Profiles::PasswordsController < Profiles::ApplicationController
  prepend PerforceSwarm::PasswordsControllerExtension
end
