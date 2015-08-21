class PerforceSwarm::GitFusionController < ApplicationController
  def new_project
    @fusion_server = params['fusion_server']
    @errors        = []
    @repos         = []
    begin
      @repos = PerforceSwarm::GitFusionRepo.list(@fusion_server)
    rescue PerforceSwarm::GitFusion::RunError => e
      @errors << e.message
    end

    respond_to do |format|
      format.html { render partial: 'new_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_new_project') } }
    end
  end
end
