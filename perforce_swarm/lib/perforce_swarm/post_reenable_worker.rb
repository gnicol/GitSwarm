require 'sidekiq'

module PerforceSwarm
  class PostReenableWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default

    def perform(repo_path, _success)
      project_namespace = repo_path.clone
      if repo_path.start_with?(Gitlab.config.gitlab_shell.repos_path.to_s)
        project_namespace.gsub!(Gitlab.config.gitlab_shell.repos_path.to_s, '')
      else
        log('Check gitlab.yml config for correct gitlab_shell.repos_path variable. ' \
            "#{Gitlab.config.gitlab_shell.repos_path} does not match #{repo_path}")
      end

      project_namespace.gsub!(/\.git\z/, '')
      project_namespace.gsub!(%r{\A/}, '')

      project = Project.find_with_namespace(project_namespace)

      if project.nil?
        log("Triggered hook for non-existing project with full path \"#{repo_path} \"")
        return false
      end

      # get mirroring status and either re-enable or disable mirroring
      repo = Repo.new(repo_path)
      reenable_complete = repo.mirrored? && Mirror.reenabling?(repo_path)
      reenable_errors   = Mirror.reenable_error(repo_path)

      # already mirrored, or mirroring is incomplete
      return true if !reenable_complete || (project.git_fusion_mirrored? && reenable_complete)

      # errors were encountered, so let's ensure that mirroring is completely off
      if reenable_errors
        project.disable_git_fusion_mirroring!
        return false
      end

      # no errors, mirroring is on, re-enabling is finished, so enable the flag
      project.update_attribute(:git_fusion_mirrored, true)
    end

    def log(message)
      Gitlab::GitLogger.error("POST-REENABLE: #{message}")
    end
  end
end
