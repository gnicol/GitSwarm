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

    def validate_and_change_in_perforce
      if username == 'root'
        p4 = PerforceSwarm::P4Connection.new
        message = p4.change_root_password(password)
        errors.add(:base, message) unless message.is_a? Array
        return false unless message.is_a? Array
      end
    end
  end
end

class User < ActiveRecord::Base
  before_validation :validate_and_change_in_perforce
  prepend PerforceSwarm::UserExtension
end
