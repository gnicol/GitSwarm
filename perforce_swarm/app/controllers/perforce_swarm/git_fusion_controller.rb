class PerforceSwarm::GitFusionController < ApplicationController
  def new_project
    @fusion_server      = params['fusion_server']
    @errors             = []
    @repos              = []
    @project_depot      = ''
    @depot_exists       = false
    @auto_create_errors = []
    @path_template      = ''
    begin
      @repos            = PerforceSwarm::GitFusionRepo.list(@fusion_server)
    rescue => e
      @errors << e.message
    end

    # attempt to connect to Perforce and ensure the desired project depot exists
    # we do this in its own rescue block so we only grab errors relevant to auto_create
    begin
      creator        = PerforceSwarm::GitFusion::RepoCreator.new(@fusion_server)
      p4             = PerforceSwarm::P4::Connection.new(creator.config)
      p4.login
      @project_depot = creator.project_depot
      @depot_exists  = PerforceSwarm::P4::Spec::Depot.exists?(creator.project_depot, p4)
      @path_template = creator.path_template.chomp('/') + '/...'
    rescue => auto_create_error
      @auto_create_errors << auto_create_error.message
    ensure
      p4.disconnect
    end

    respond_to do |format|
      format.html { render partial: 'new_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_new_project') } }
    end
  end
end
