class PerforceSwarm::GitFusionController < ApplicationController
  def existing_project
    init_auto_create

    begin
      # get the desired project and throw if it is already mirrored
      @project = Project.find(params['project_id'])
      fail 'This project is already mirrored in Helix.' if @project.git_fusion_mirrored?
      fail 'This project is already associated to a Helix Git Fusion repository.' if @project.git_fusion_repo.present?

      # first verify we can talk to git-fusion successfully, add error out with details if we cannot
      begin
        PerforceSwarm::GitFusion.run(@fusion_server, 'info')
      rescue => error
        raise 'There was an error communicating with Helix Git Fusion: ' + error.message
      end

      # pre-flight checks against Git Fusion and Perforce
      creator = PerforceSwarm::GitFusion::RepoCreator.new(@fusion_server, @project.namespace.name, @project.path)
      p4      = PerforceSwarm::P4::Connection.new(creator.config)
      p4.login
      creator.save_preflight(p4)

      @path_template = creator.depot_path + '/...'
    rescue => error
      @errors << error.message
    ensure
      p4.disconnect if p4
    end

    respond_to do |format|
      format.html { render partial: 'existing_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_existing_project') } }
    end
  end

  def new_project
    init_auto_create

    begin
      @repos = PerforceSwarm::GitFusionRepo.list(@fusion_server, current_user.username)
    rescue => e
      @errors << e.message
    end

    begin
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

    respond_to do |format|
      format.html { render partial: 'new_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_new_project') } }
    end
  end

  protected

  def init_auto_create
    @fusion_server      = params['fusion_server']
    @errors             = []
    @repos              = []
    @project_depot      = ''
    @depot_exists       = false
    @auto_create_errors = []
    @path_template      = ''
  end
end
