require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def save!
      if username == 'root'
        validate_and_change_in_p4d { |message| return message }
      else
        super
      end
    end

    def validate_and_change_in_p4d(&block)
      # presently we only handle the 'root' user and only for auto-provisioned servers
      # run only if were changing password
      return unless changed.include?('encrypted_password') && username == 'root'
      sync_p4d_password(password)
    rescue P4Exception => ex
      block.call(ex.message) if block_given?
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
        message = ex.message.match(/\[Error\]: (?<error>.*)$/) ? Regexp.last_match(:error) : ex.message
        raise ex, message
      end
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_p4d
  prepend PerforceSwarm::UserExtension
end
