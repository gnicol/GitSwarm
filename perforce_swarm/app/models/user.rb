require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      if username == 'root'
        @config = PerforceSwarm::Config.new
        p4 = PerforceSwarm::P4Connection.new(PerforceSwarm::GitFusion::ConfigEntry.new(@config))
        p4.login
        p4.input(password)
        begin
          p4.run('passwd', 'root')
        rescue P4Exception => ex
          message = ex.message.match(/\[Error\]: (?<message>.*)$/)
          flash.now[:alert] = message['message']
          return false
        end
      end
      super
    end
  end
end

class User < ActiveRecord::Base
  prepend PerforceSwarm::UserExtension
end
