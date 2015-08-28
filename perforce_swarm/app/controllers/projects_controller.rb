require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def project_params
      params[:git_fusion_auto_create] = params[:git_fusion_auto_create] == 'true'

      # if we were given git fusion parameters, incorporate those now
      if params[:git_fusion_entry] && !params[:git_fusion_entry].blank? &&
         params[:git_fusion_repo_name] && !params[:git_fusion_repo_name].blank?
        params[:git_fusion_repo] = "mirror://#{params[:git_fusion_entry]}/#{params[:git_fusion_repo_name]}"
      end

      super.merge(params.permit(:git_fusion_repo, :git_fusion_auto_create, :git_fusion_entry))
    end
  end
end

class ProjectsController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerExtension
  prepend PerforceSwarm::ProjectsControllerHelper
  before_filter :add_project_gon_variables
end
