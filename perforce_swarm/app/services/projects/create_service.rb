require Rails.root.join('app', 'services', 'projects', 'create_service')

module PerforceSwarm
  module CreateServiceExtensions
    def after_create_actions
      # user has chosen to import via Git Fusion
      if @params[:git_fusion_repo]
        # ensure project is marked as a git fusion import
        @project.update_column(:import_type, 'git_fusion')

        # create mirror remote
        log_info("Creating Git remote mirror for '#{@project.git_fusion_repo}'.")
        PerforceSwarm::Repo.new(@project.repository.path_to_repo).mirror_url = @project.git_fusion_repo

        # kick off and background initial import task
        log_info("Kicking off initial import for '#{@project.git_fusion_repo}'.")
        import_job = fork do
          mirror_script =
              File.join(File.expand_path(Gitlab.config.gitlab_shell.path), 'perforce_swarm', 'bin', 'gitswarm-mirror')
          exec Shellwords.shelljoin(mirror_script, 'fetch', @project.path_with_namespace + '.git')
        end
        Process.detach(import_job)
      end
      super.after_create_actions
    end
  end
end

module Projects
  class CreateService
    prepend PerforceSwarm::CreateServiceExtensions
  end
end
