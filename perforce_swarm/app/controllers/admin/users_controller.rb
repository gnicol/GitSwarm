require Rails.root.join('app', 'controllers', 'admin', 'users_controller')

module PerforceSwarm
  module UsersControllerExtension
    def update
      if params[:user][:username] == 'root' && !params[:user][:password_confirmation].empty?
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

class Admin::UsersController < Admin::ApplicationController
  prepend PerforceSwarm::UsersControllerExtension
end
