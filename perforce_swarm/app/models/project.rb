require Rails.root.join('app', 'models', 'project')

module PerforceSwarm
  module Project
    def add_import_job
      # no git fusion repo, so carry on with normal import behaviour
      return super unless git_fusion_import?

      # we have a git fusion import request- ensure project is marked as imported from git fusion
      update_column(:import_type, 'git_fusion')

      # create mirror remote
      PerforceSwarm::Repo.new(repository.path_to_repo).mirror_url = git_fusion_repo

      # kick off and background initial import task
      import_job = fork do
        mirror_script =
            File.join(File.expand_path(Gitlab.config.gitlab_shell.path), 'perforce_swarm', 'bin', 'gitswarm-mirror')
        exec Shellwords.shelljoin([mirror_script, 'fetch', path_with_namespace + '.git'])
      end
      Process.detach(import_job)
    end

    def import_in_progress?
      (import? || git_fusion_import?) && import_status == 'started'
    end

    def git_fusion_import?
      git_fusion_repo.present?
    end
  end
end

class Project < ActiveRecord::Base
  validates :git_fusion_repo,
            length: { within: 0..255 }
  prepend PerforceSwarm::Project
end
