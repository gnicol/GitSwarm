module PerforceSwarm
  module GitFusion
    class RepoAccessCache
      attr_reader :user, :server

      def initialize(user, server)
        @user   = user
        @server = server
      end

      def cache_key
        "git_fusion_repo_access:#{user.username}-server-#{server}"
      end

      def cache_content
        Rails.cache.fetch(cache_key) do
          access = Hash.new
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

      def self.clear_cache(username)
        Rails.cache.delete_matched("git_fusion_repo_access:#{username}-server-*")
      end

      def self.repo_access?(user, repo)
        new(user, server_id_from_repo(repo)).repos.include?(repo)
      end

      def self.server_id_from_repo(repo)
        repo.sub(%r{^mirror://}, '').split('/', 2)[0]
      end
    end
  end
end
