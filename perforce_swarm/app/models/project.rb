require Rails.root.join('app', 'models', 'project')

module PerforceSwarm
  module ProjectExtension
    def import_in_progress?
      return true if git_fusion_import? && import_status == 'started'
      super
    end

    def git_fusion_import?
      git_fusion_repo.present?
    end
  end
end

class Project < ActiveRecord::Base
  validates :git_fusion_repo, length: { maximum: 255 }, allow_blank: true
  prepend PerforceSwarm::ProjectExtension

  # The rspec tests use 'allow_any_instance_of' on Project to stub this method out during testing.
  # Unfortunately, if we 'prepend' our modifications that goes into an endless loop. So we monkey it.
  # @todo If rspec ever fixed prepend handling; move this to ProjectExtension. Or fix rspec ourselves!
  alias_method :add_import_job_super, :add_import_job
  def add_import_job
    # no git fusion repo, so carry on with normal import behaviour
    return add_import_job_super unless git_fusion_import?

    # we have a git fusion import request- ensure project is marked as imported from git fusion
    update_column(:import_type, 'git_fusion')

    # create mirror remote
    PerforceSwarm::Repo.new(repository.path_to_repo).mirror_url = git_fusion_repo

    # kick off and background initial import task
    import_job = fork do
      gitlab_shell  = File.expand_path(Gitlab.config.gitlab_shell.path)
      mirror_script = File.join(gitlab_shell, 'perforce_swarm', 'bin', 'gitswarm-mirror')
      exec Shellwords.shelljoin([mirror_script, 'fetch', path_with_namespace + '.git'])
    end
    Process.detach(import_job)
  end
end
