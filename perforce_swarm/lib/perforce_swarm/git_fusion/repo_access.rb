module PerforceSwarm
  module GitFusion
    class RepoAccess
      attr_reader :user, :server, :server_config

      def initialize(user, server)
        @user   = user
        @server = server
      end

      def cache_key
        "git_fusion_repo_access:#{user.username}-server-#{server}"
      end

      def cache_content
        Rails.cache.fetch(cache_key) do
          access = {}
          access[:cached_at] = Time.new
          access[:repos]     = []
          begin
            PerforceSwarm::GitFusionRepo.list(server, user.username).each_key do |repo_name|
              access[:repos] << "mirror://#{server}/#{repo_name}"
            end
          rescue PerforceSwarm::GitFusion::RunError => e
            Gitlab::AppLogger.error(e.message)
          end
          access
        end
      end

      def repos
        cache_content[:repos] || []
      end

      def self.clear_cache(username: '*', server: '*')
        Rails.cache.delete_matched("git_fusion_repo_access:#{username}-server-#{server}")
      end

      # User is a User object, projects is an iterable of objects with git_fusion_repo accessors
      def self.filter_by_p4_access(user, projects = [])
        # Find fusion_repos from private projects to filter by access
        fusion_repos        = projects.map { |project| !project.private? ? nil : project.git_fusion_repo }.compact
        gitlab_shell_config = PerforceSwarm::GitlabConfig.new

        # Grab mirrored projects from list and determine unique gf servers and
        # repos that we want to enforce read permissions on
        enforced_repos   = []
        enforced_servers = []
        fusion_repos.each do |repo|
          server = server_id_from_repo(repo)

          # Grab the server config for this repo
          begin
            server_config = gitlab_shell_config.git_fusion.entry(server)
          rescue
            server_config = nil
          end

          # enforce read permissions if the git-fusion server exists
          # in the config, and has the enforce_permissions config flag set to true
          if server_config && server_config.enforce_permissions?
            enforced_servers << server
            enforced_repos   << repo
          end
        end
        enforced_servers.uniq!
        enforced_repos.uniq!

        # Get the list of readable repos against each server
        readable_repos = []
        enforced_servers.each { |server| readable_repos += new(user, server).repos }

        # Determine the list of blocked repos and filter the projects accordingly
        no_access = enforced_repos - readable_repos

        # Allow access if project is not mirrored, or not marked private, or is not in the no_access list
        projects.select do |project|
          !project.git_fusion_mirrored? || !project.private? || !no_access.include?(project.git_fusion_repo)
        end
      end

      def self.access?(user, project)
        !filter_by_p4_access(user, [project]).empty?
      end

      def self.server_id_from_repo(repo)
        repo.sub(%r{^mirror://}, '').split('/', 2)[0]
      end
    end
  end
end
