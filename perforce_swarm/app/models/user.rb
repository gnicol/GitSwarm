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

    def git_fusion_repo_cache_key(server)
      "git_fusion_repo_access:#{username}-server-#{server}"
    end

    def git_fusion_repo_access(server)
      Rails.cache.fetch(git_fusion_repo_cache_key(server)) do
        access = Hash.new
        access[:cached_at]    = Time.new
        access[:server_repos] = []
        begin
          PerforceSwarm::GitFusionRepo.list(server, username).each_key do |repo_name|
            access[:server_repos] << "mirror://#{server}/#{repo_name}"
          end
        rescue PerforceSwarm::GitFusion::RunError => e
          Gitlab::AppLogger.error(e.message)
        end
        access
      end
    end

    def clear_git_fusion_repo_cache
      Rails.cache.delete_matched("git_fusion_repo_access:#{username}-server-*")
    end

    # Projects user has access to
    def authorized_projects
      return @authorized_projects if @authorized_projects

      gitab_auth_projects = super
      gitlab_shell_config = PerforceSwarm::GitlabConfig.new

      # Grab mirrored projects from list and determine unique gf servers and
      # repos that we want to enforce read permissions on
      enforce_read_repos   = []
      enforce_read_servers = []
      gitab_auth_projects.pluck(:git_fusion_repo).compact.each do |repo|
        server = repo.sub(%r{^mirror://}, '').split('/', 2)[0]

        # Grab the server config for this repo
        begin
          server_config = gitlab_shell_config.git_fusion.entry(server)
        rescue
          server_config = nil
        end

        # enforce read permissions if the git-fusion server no longer exists
        # in the config, or if it exists and has the enforce_permissions
        # config flag set to true
        if !server_config || server_config.enforce_permissions?
          enforce_read_servers << server
          enforce_read_repos << repo
        end
      end
      enforce_read_servers.uniq!

      # Get the list of readable repos against each server
      readable_repos = []
      enforce_read_servers.each { |server| readable_repos += git_fusion_repo_access(server)[:server_repos] }

      # Determine which repos you don't have access to
      no_access_repos = enforce_read_repos - readable_repos

      # Remove projects with those repos from your auth projects
      project_ids = gitab_auth_projects.reject { |project| no_access_repos.include?(project.git_fusion_repo) }.map(&:id)

      # Callers are expecting an ActiveRecord result, so do another query for the authorized_projects
      @authorized_projects = Project.where(id: project_ids)
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_p4d
  prepend PerforceSwarm::UserExtension
end
