require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      message = sync_p4d_password(password)
      return message unless message.is_a? Array
      super
    end

    def validate_and_change_in_perforce
      message = sync_p4d_password(password)
      errors.add(:base, message) unless message.is_a? Array
      return false unless message.is_a? Array
    end

    def sync_p4d_password(password)
      # presently we only handle the 'root' user and only for auto-provisioned servers
      return unless username == 'root'
      default_config = PerforceSwarm::GitlabConfig.new.git_fusion.entry('default')
      return unless default_config['auto_provision'] == true

      connection = PerforceSwarm::P4::Connection.new(default_config)
      connection.login
      connection.input(password)
      begin
        connection.run('passwd', 'root')
      rescue P4Exception => ex
        message = ex.message.match(/\[Error\]: (?<message>.*)$/)
        message['message']
      end
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_perforce
  prepend PerforceSwarm::UserExtension
end
