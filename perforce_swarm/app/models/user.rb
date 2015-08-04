require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      PerforceSwarm::P4DManager.update_p4d_root_password(password)
      super
    end
  end
end

class User < ActiveRecord::Base
  prepend PerforceSwarm::UserExtension
end
