require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def project_params
      # if we were given git fusion parameters, incorporate those now
      if params[:git_fusion_repo_name]
        params[:git_fusion_repo] =
            'mirror://' + (params[:git_fusion_entry] || 'default') + '/' + params[:git_fusion_repo_name]
      end
      super.merge(params.permit(:git_fusion_repo))
    end
  end
end

class ProjectsController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerExtension
  prepend PerforceSwarm::ProjectsControllerHelper
  before_filter :add_project_gon_variables
end
