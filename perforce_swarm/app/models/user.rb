require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      message = sync_p4d_password(password)
      return message unless message.is_a? Array
      super
    end

    def validate_and_change_in_p4d
      # presently we only handle the 'root' user and only for auto-provisioned servers
      # run only if were changing password
      return unless @changed_attributes.key?('encrypted_password') && username == 'root'
      sync_p4d_password(password)
    rescue P4Exception => ex
      errors.add(:base, ex.message)
      return false
    rescue RuntimeError
      # rescue RunTime error - which will be raised if git fusion config does not have a default
      return true
    end

    def sync_p4d_password(password)
      default_config = PerforceSwarm::GitlabConfig.new.git_fusion.entry('default')
      return unless default_config['auto_provision']

      connection = PerforceSwarm::P4::Connection.new(default_config)
      connection.login
      connection.input(password)
      begin
        connection.run('passwd', 'root')
      rescue P4Exception => ex
        message = Regexp.last_match(:error) if ex.message.match(/\[Error\]: (?<error>.*)$/)
        raise ex, message
      end
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_p4d
  prepend PerforceSwarm::UserExtension
end
