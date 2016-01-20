require Rails.root.join('app', 'models', 'user')

module PerforceSwarm
  module UserExtension
    def validate_and_change_in_p4d
      # presently we only handle the 'root' admin user and only for auto-provisioned servers
      # runs only if we're changing password
      return true unless changed.include?('encrypted_password') && username == 'root' && admin
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
      git_fusion = PerforceSwarm::GitlabConfig.new.git_fusion
      return unless git_fusion.enabled?

      begin
        connection = PerforceSwarm::P4::Connection.new(git_fusion.auto_provisioned_entry)
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

    # Projects user has access to
    def authorized_projects
      # Our ActiveRecord relation ends up being turned into an array, so we grab just the ids
      project_ids = GitFusion::RepoAccess.filter_by_p4_access(self, super).map(&:id)

      # Callers are expecting an ActiveRecord result, so do another query for the authorized_projects
      Project.where(id: project_ids)
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_p4d
  prepend PerforceSwarm::UserExtension
end
