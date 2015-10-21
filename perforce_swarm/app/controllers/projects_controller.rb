require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def configure_mirroring
      @errors = [] unless @errors
      ensure_not_mirrored

      # users can only enable mirroring for an existing project at this point
      render 'perforce_swarm/git_fusion/projects/configure_mirroring'
    end

    # actually performs the task of mirroring on the specified project and repo server
    def enable_mirroring
      @errors = []
      ensure_not_mirrored

      # pre-flight the specified Git Fusion repo
      # create the p4gf_config file, which creates the repo in Git Fusion
      # if this was successful, modify the project to include the mirror URL
      # kick off a background fetch operation
      # any errors occurring in the above are shown on the configure_mirroring page
      @errors << 'This is a potential error from configuring mirroring.'
      redirect_to(
          configure_mirroring_namespace_project_path(@project.namespace, @project)
      )
    end

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

    def ensure_not_mirrored
      # if the project is already mirrored, redirect back to the project page with a flash message
      redirect_to(
          project_path(@project),
          notice: 'Project is already mirrored in Helix.'
      ) if @project.git_fusion_repo.present?
    end

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
