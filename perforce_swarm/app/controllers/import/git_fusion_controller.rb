class Import::GitFusionController < Import::BaseController
  def select_repos
    @fusion_server = params['fusion_server']
  end
end