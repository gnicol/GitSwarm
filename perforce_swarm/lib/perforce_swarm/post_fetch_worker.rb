require 'rubygems'
require 'sidekiq'
require 'sidetiq'

module PerforceSwarm
  class PostFetch
    include Sidekiq::Worker

    sidekiq_options queue: :perforce_swarm_post_fetch

    def perform(repo_path, success)
      project_namespace = repo_path
      if repo_path.start_with?(Gitlab.config.gitlab_shell.repos_path.to_s)
        project_namespace.gsub!(Gitlab.config.gitlab_shell.repos_path.to_s, '')
      else
        log('Check gitlab.yml config for correct gitlab_shell.repos_path variable. ' \
            "#{Gitlab.config.gitlab_shell.repos_path} does not match #{repo_path}")
      end

      project_namespace.gsub!(/\.git\z/, '')
      project_namespace.gsub!(/\A\//, '')

      project = Project.find_with_namespace(project_namespace)

      if project.nil?
        log("Triggered hook for non-existing project with full path \"#{repo_path} \"")
        return false
      end

      log("Triggered for #{project.inspect} #{success.inspect}")
    end

    def log(message)
      Gitlab::GitLogger.error("POST-FETCH: #{message}")
    end
  end
end
