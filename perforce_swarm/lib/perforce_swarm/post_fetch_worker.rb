require 'sidekiq'
require 'sidetiq'

module PerforceSwarm
  class PostFetchWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default

    def perform(repo_path, _success)
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

      # if we thought a git-fusion import was ongoing; flag it as finished
      if project.import_in_progress? && project.git_fusion_import?
        project.finish
        project.save
      end
    end

    def log(message)
      Gitlab::GitLogger.error("POST-FETCH: #{message}")
    end
  end
end
