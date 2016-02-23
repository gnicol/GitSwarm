require Rails.root.join('app', 'models', 'project')

module PerforceSwarm
  module ProjectExtension
    # Git Fusion re-enable constants
    GIT_FUSION_REENABLE_IN_PROGRESS = 'in_progress'
    GIT_FUSION_REENABLE_ERROR       = 'error'
    GIT_FUSION_REENABLE_MIRRORED    = 'mirrored'
    GIT_FUSION_REENABLE_UNMIRRORED  = 'unmirrored'

    # Git Fusion repo creation types
    GIT_FUSION_REPO_CREATION_DISABLED    = 'disabled'
    GIT_FUSION_REPO_CREATION_AUTO_CREATE = 'auto-create'
    GIT_FUSION_REPO_CREATION_IMPORT_REPO = 'import-repo'
    GIT_FUSION_REPO_CREATION_FILE_SELECT = 'file-selector'

    def import_in_progress?
      return true if git_fusion_mirrored? && import_status == 'started'
      super
    end

    # disables Git Fusion mirroring on the project, and removes the mirror remote
    # on the bare GitSwarm repo
    def disable_git_fusion_mirroring!
      update_attribute(:git_fusion_mirrored, false)
      # remove the mirror remote, which will turn off mirroring in gitlab-shell
      PerforceSwarm::Repo.new(repository.path_to_repo).mirror_url = nil
    end

    # enables Git Fusion mirroring on the project with the specified server and
    # repo name, and creates the mirror remote on the GitSwarm bare repo
    def enable_git_fusion_mirroring!(fusion_server, repo_name)
      # update_attributes will validate the values it has been passed
      update_attributes(git_fusion_repo: "mirror://#{fusion_server}/#{repo_name}",
                        git_fusion_mirrored: true
                       )
      PerforceSwarm::Repo.new(repository.path_to_repo).mirror_url = git_fusion_repo
    end

    def create_repository
      # Attempt to submit the config for a new GitFusion repo to perforce if
      # git_fusion_repo_create_type of auto-create was set on this project
      if git_fusion_entry.present? &&
          (git_fusion_repo_create_type == GIT_FUSION_REPO_CREATION_AUTO_CREATE ||
          git_fusion_repo_create_type == GIT_FUSION_REPO_CREATION_FILE_SELECT)
        begin
          creator = PerforceSwarm::GitFusion::AutoCreateRepoCreator.new(git_fusion_entry, namespace.name, path)
          creator.save
          PerforceSwarm::GitFusion::RepoAccess.clear_cache(server: git_fusion_entry)

          # GitFusion Repo has been created, flag this project for import
          # We choose to always import from GitFusion because there may have
          # been perforce changes that will come down, even on a new repo
          self.git_fusion_repo     = "mirror://#{git_fusion_entry}/#{creator.repo_name}"
          self.git_fusion_mirrored = true
          save

          true
        rescue ::P4Exception, PerforceSwarm::GitFusion::RepoCreatorError => e
          errors.add(:base, e.message)
          return false
        end
      end
      super
    end

    def git_fusion_reenable_status
      repo_path = repository.path_to_repo
      repo      = PerforceSwarm::Repo.new(repo_path)
      # we're in progress if we're currently re-enabling or we're waiting for
      # the redis event to complete
      if PerforceSwarm::Mirror.reenabling?(repo_path) || (!git_fusion_mirrored? && repo.mirrored?)
        return GIT_FUSION_REENABLE_IN_PROGRESS
      elsif git_fusion_mirrored?
        return GIT_FUSION_REENABLE_MIRRORED
      else
        error = git_fusion_reenable_error
        return error ? GIT_FUSION_REENABLE_ERROR : GIT_FUSION_REENABLE_UNMIRRORED
      end
    rescue
      return GIT_FUSION_REENABLE_ERROR
    end

    def git_fusion_reenable_error
      PerforceSwarm::Mirror.reenable_error(repository.path_to_repo)
    end

    def git_fusion_repo_segments
      return [] unless git_fusion_repo.present?
      git_fusion_repo.sub(%r{^mirror://}, '').split('/', 2)
    end

    def git_fusion_server_id
      git_fusion_repo_segments[0]
    end

    def git_fusion_repo_name
      git_fusion_repo_segments[1]
    end
  end
end

class Project < ActiveRecord::Base
  validates :git_fusion_repo,
            length: { maximum: 255 },
            allow_blank: true,
            allow_nil: true,
            format: { with: %r{\Amirror://([^/]+)/([^/]+(/[^/]+)*)\z},
                      message: 'must be a valid Git Fusion repo to enable mirroring.' },
            if: ->(project) { project.git_fusion_repo.present? }
  prepend PerforceSwarm::ProjectExtension

  attr_accessor :git_fusion_repo_create_type
  attr_accessor :git_fusion_entry
  attr_accessor :git_fusion_branch_mappings

  # The rspec tests use 'allow_any_instance_of' on Project to stub this method out during testing.
  # Unfortunately, if we 'prepend' our modifications that goes into an endless loop. So we monkey it.
  # @todo If rspec ever fixed prepend handling; move this to ProjectExtension. Or fix rspec ourselves!
  alias_method :add_import_job_super, :add_import_job

  def add_import_job
    # no git fusion repo, so carry on with normal import behaviour
    return add_import_job_super unless git_fusion_mirrored?

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

  # we don't include this in the ProjectExtension due to RSpec not allowing us
  # to stub it out - see the comment above for details
  def git_fusion_mirrored?
    git_fusion_repo.present? && git_fusion_mirrored
  end
end
