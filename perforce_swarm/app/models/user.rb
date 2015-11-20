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
      id         = git_fusion.auto_provisioned_instance_id
      return unless git_fusion.enabled? && !id.nil?

      begin
        connection = PerforceSwarm::P4::Connection.new(git_fusion.entry(id))
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

    def git_fusion_repo_access(server)
      key = "git_fusion_repo_access:user_#{id}_server_#{server}"
      Rails.cache.fetch(key) do
        server_repos = []
        begin
          PerforceSwarm::GitFusionRepo.list(server, username).each_key do |repo_name|
            server_repos << "mirror://#{server}/#{repo_name}"
          end
        rescue PerforceSwarm::GitFusion::RunError => e
          Gitlab::AppLogger.error(e.message)
        end
        server_repos
      end
    end

    # Projects user has access to
    def authorized_projects
      return @authorized_projects if @authorized_projects

      gitab_auth_projects = super

      # Grab mirrored projects from list
      fusion_repos = gitab_auth_projects.pluck(:git_fusion_repo).compact

      # Determine unique gf servers
      gf_servers = fusion_repos.map { |repo| repo.sub(%r{^mirror://}, '').split('/', 2)[0] }
      gf_servers.uniq!

      # Run @list against each server
      gf_repos = []
      gf_servers.each do |server|
        gf_repos += git_fusion_repo_access(server)
      end

      # Determine which repos you don't have access to
      no_access = fusion_repos - gf_repos

      # Remove projects with those repos from your auth projects
      project_ids = gitab_auth_projects.reject { |project| no_access.include?(project.git_fusion_repo) }.map(&:id)

      @authorized_projects = Project.where(id: project_ids)
    end
  end
end

class User < ActiveRecord::Base
  before_save :validate_and_change_in_p4d
  prepend PerforceSwarm::UserExtension
end
