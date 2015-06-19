class Import::GitFusionController < Import::BaseController
  before_action :verify_git_fusion_import_enabled

  def status
    @already_added_projects = current_user.created_projects.where(import_type: 'git_fusion')
    already_added_projects_names = @already_added_projects.pluck(:import_source)

    @repos = @repos.to_a.reject { |repo| already_added_projects_names.include? repo['path_with_namespace'] }
  end

  def jobs
    jobs = current_user.created_projects.where(import_type: 'git_fusion').to_json(only: [:id, :import_status])
    render json: jobs
  end

  def new
    # TODO: filter out already-mirrored repos?
    @repos       = PerforceSwarm::GitFusion::Repo.list('git@192.168.1.75')
    @repo_select = []
    @repos.each do |name, _description|
      @repo_select.push([name, name])
    end
  end

  def create
    @repo_id = params[:repo_id]
    # TODO: include git fusion URL from object
    repo = { name: @repo_id, description: client[@repo_id], clone_url: 'git@192.168.1.75/' + @repo_id }
    @project_name = @repo_id
    @target_namespace = current_user.namespace
    @repo_select = []
    namespace = get_or_create_namespace || (render && return)

    @project = Gitlab::GitFusionImport::ProjectCreator.new(repo, namespace, current_user).execute
  end

  private

  def verify_git_fusion_import_enabled
    # TODO: check for whether git fusion imports are enabled
    true
  end
end
