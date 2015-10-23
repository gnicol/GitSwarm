class PerforceSwarm::GitFusionController < ApplicationController
  def existing_project
    initialize_variables
    populate_repos

    begin
      @project       = Project.find(params['project_id'])
      repo_creator   = PerforceSwarm::GitFusion::RepoCreator.new(@fusion_server)
      @path_template = repo_creator.namespace(project.namespace.name).project_path(project.path).depot_path + '/...'

      # pre-flight checks:
      #   * the project is already mirrored
      #   * both the project and //.git-fusion depots exist
      #   * Git Fusion doesn't already have a config for this project
      #   * there is no content in our destination depot for project files
      fail 'This project appears to already be mirrored. Please contact your administrator if you believe this is ' \
           'an error.' if @project.git_fusion_repo.present?
      repo_creator.ensure_depots_exist
      alternate_message = 'GitSwarm will be unable to mirror to this location, but you ' \
                          'can import the existing Git Fusion repository into a new project.'

      if repo_creator.p4gf_config_exists?
        fail 'It appears that a Git Fusion repository has already been created for that location. ' + alternate_message
      end

      if repo_creator.depot_path_content?
        fail "It appears that there is already content in Helix at #{repo_creator.depot_path}. " + alternate_message
      end
    rescue => error
      @errors << ERB::Util.html_escape(error)
    end

    respond_to do |format|
      format.html { render partial: 'mirror_selector', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_mirror_selector') } }
    end
  end

  def new_project
    initialize_variables
    populate_repos
    populate_auto_create

    respond_to do |format|
      format.html { render partial: 'new_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_new_project') } }
    end
  end

  protected

  def initialize_variables
    @fusion_server      = params['fusion_server']
    @errors             = []
    @repos              = []
    @project_depot      = ''
    @depot_exists       = false
    @auto_create_errors = []
    @path_template      = ''
  end

  def populate_auto_create
    # attempt to connect to Perforce and ensure the desired project depot exists
    # we do this in its own rescue block so we only grab errors relevant to auto_create
    creator        = PerforceSwarm::GitFusion::RepoCreator.new(@fusion_server)
    p4             = PerforceSwarm::P4::Connection.new(creator.config)
    p4.login
    @project_depot = creator.project_depot
    @depot_exists  = PerforceSwarm::P4::Spec::Depot.exists?(p4, creator.project_depot)
    @path_template = creator.path_template.chomp('/') + '/...'
  rescue => auto_create_error
    @auto_create_errors << auto_create_error.message
  ensure
    p4.disconnect if p4
  end

  def populate_repos
    @repos = PerforceSwarm::GitFusionRepo.list(@fusion_server)
  rescue => e
    @errors << e.message
  end
end
