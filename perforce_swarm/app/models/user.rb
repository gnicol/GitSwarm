require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      if username == 'root'
        p4 = PerforceSwarm::P4Connection.new
        message = p4.change_root_password(password)
        return message if message
      end
      super
    end
  end
end

class User < ActiveRecord::Base
  prepend PerforceSwarm::UserExtension
end
