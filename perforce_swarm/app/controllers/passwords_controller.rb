require Rails.root.join('app', 'controllers', 'passwords_controller')

module PerforceSwarm
  module PasswordsControllerExtension
    def update
      token = resource_params[:reset_password_token]
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token)
      if User.where(reset_password_token: reset_password_token).first.id == 1
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

class PasswordsController < Devise::PasswordsController
  prepend PerforceSwarm::PasswordsControllerExtension
end
