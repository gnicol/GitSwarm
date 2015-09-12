require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def project_params
      params[:git_fusion_auto_create] = param_from_string(params[:git_fusion_auto_create])

      # if we were given git fusion parameters, incorporate those now
      if params[:git_fusion_entry] && !params[:git_fusion_entry].blank? &&
         params[:git_fusion_repo_name] && params[:git_fusion_auto_create] == false
        params[:git_fusion_repo] = "mirror://#{params[:git_fusion_entry]}/#{params[:git_fusion_repo_name]}"
      end

      super.merge(params.permit(:git_fusion_repo, :git_fusion_auto_create, :git_fusion_entry))
    end

    protected

    def param_from_string(str)
      case str
      when 'true'
        return true
      when 'false'
        return false
      when 'nil'
        return nil
      else
        return str
      end
    end
  end
end

class ProjectsController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerExtension
  prepend PerforceSwarm::ProjectsControllerHelper
  before_filter :add_project_gon_variables
end
