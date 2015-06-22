require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      logger.info("Send new root password to p4d. #{password}")
      super
    end
  end
end

class User < ActiveRecord::Base
  prepend PerforceSwarm::UserExtension
end
