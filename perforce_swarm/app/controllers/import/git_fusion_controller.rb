class Import::GitFusionController < Import::BaseController
  def configure
    @fusion_server = params['fusion_server']

    respond_to do |format|
      format.html { render partial: 'config', layout: false }
      format.json { render json: { html: view_to_html_string('import/git_fusion/_config') } }
    end
  end
end
