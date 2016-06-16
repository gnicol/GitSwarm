require Rails.root.join('app', 'workers', 'repository_import_worker')

class GitFusionImportWorker < RepositoryImportWorker
  def perform(project_id)
    @project = Project.find(project_id)

    # not a Git Fusion import
    unless project.import_type && project.import_type == 'git_fusion'
      raise Error, 'Git Fusion import requested against a project of the wrong type.'
    end

    # project is mirrored in Git Fusion, so create the repository first and perform
    # the import in the background
    unless project.create_repository
      raise Error, 'The repository could not be created.'
    end

    # create mirror remote
    PerforceSwarm::Repo.new(project.repository.path_to_repo).mirror_url = project.git_fusion_repo

    # kick off and background initial import task
    import_job = fork do
      gitlab_shell = File.expand_path(Gitlab.config.gitlab_shell.path)
      mirror_script = File.join(gitlab_shell, 'perforce_swarm', 'bin', 'gitswarm-mirror')
      exec Shellwords.shelljoin(
        [mirror_script, 'fetch', '--redis-on-finish', project.path_with_namespace + '.git']
      )
    end
    Process.detach(import_job)
  rescue => e
    project.update(import_error: Gitlab::UrlSanitizer.sanitize(e.message))
    project.import_fail
    return
  end
end
