require Rails.root.join('app', 'models', 'project')

module PerforceSwarm
  module ProjectExtension
    def import_in_progress?
      return true if git_fusion_import? && import_status == 'started'
      super
    end

    def git_fusion_import?
      git_fusion_repo.present? && !git_fusion_auto_create
    end

    def create_repository
      if !git_fusion_entry.blank? && git_fusion_auto_create
        # creator = PerforceSwarm::GitFusion::RepoCreator.new(git_fusion_entry, namespace: self.namespace.name, project
        # puts creator.generate_depot_path
        git_fusion_repo = "mirror://#{git_fusion_entry}/#{path}"
      end

      super
    end
  end
end

class Project < ActiveRecord::Base
  validates :git_fusion_repo, length: { maximum: 255 }, allow_blank: true
  validates :git_fusion_repo, presence: true, unless: "git_fusion_entry.blank? || git_fusion_auto_create"
  prepend PerforceSwarm::ProjectExtension

  attr_accessor :git_fusion_auto_create
  attr_accessor :git_fusion_entry

  # run our code after the GL validations are done
  # before_save :auto_create_git_fusion, if: :git_fusion_auto_create


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
      exec Shellwords.shelljoin([mirror_script, 'fetch', '--redis-on-finish', path_with_namespace + '.git'])
    end
    Process.detach(import_job)
  end
end
