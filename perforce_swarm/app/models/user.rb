require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def validate_and_change_in_p4d
      # presently we only handle the 'root' user and only for auto-provisioned servers
      # run only if were changing password
      return true unless changed.include?('encrypted_password') && username == 'root'
      sync_p4d_password(password)
    rescue P4Exception => ex
      # if a p4 error occurs; attempt to raise it to the user's attention and abort the save
      errors.add(:base, ex.message)
      return false
    rescue
      # for any other exception (e.g. the default git-fusion entry isn't present)
      # just report success for this step and let save proceed.
      return true
    end

    def sync_p4d_password(password)
      default_config = PerforceSwarm::GitlabConfig.new.git_fusion.entry('default')
      return unless default_config['auto_provision']

      begin
        connection = PerforceSwarm::P4::Connection.new(default_config)
        connection.login
        connection.input(password)
        connection.run('passwd', 'root')
      rescue P4Exception => ex
        message = ex.message.match(/\[Error\]: (?<error>.*)$/) ? Regexp.last_match(:error) : ex.message
        raise ex, message
      ensure
        connection.disconnect if connection
      end
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_p4d
  prepend PerforceSwarm::UserExtension
end
