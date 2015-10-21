require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def configure_mirroring
      @errors = []
      # if the project is already mirrored, redirect back to the project page with a flash message
      if @project.git_fusion_repo.present?
        redirect_to(
            project_path(@project),
            alert: 'Project is already mirrored in Helix.'
        )
        return
      end

      # users can only enable mirroring for an existing project at this point
      render 'perforce_swarm/git_fusion/projects/configure_mirroring'
    end

    # actually performs the task of mirroring on the specified project and repo server
    def enable_mirroring
      # ensure we're not already mirrored
      fail 'Project is already mirrored in Helix.' if @project.git_fusion_repo.present?

      fusion_server = params['fusion_server']
      repo_creator  = PerforceSwarm::GitFusion::RepoCreator.new(fusion_server)
      repo_creator.namespace(@project.namespace.name).project_path(@project.path)

      # create the p4gf_config file, which creates the repo in Git Fusion
      repo_creator.save

      # modify the project to include the mirror URL
      @project.update_column(:git_fusion_repo, 'mirror://' + fusion_server + '/' + repo_creator.repo_name)

      # kick off a background fetch operation

      fail 'Repo field updated to: ' + @project.git_fusion_repo
    rescue => e
      # any errors occurring in the above are shown on the configure_mirroring page, but if we've
      # gotten as far as mirroring, this will cause a double redirect, so we hit the project details page
      redirect_location = @project.git_fusion_repo.present? ? project_path(@project) : :back
      redirect_to(redirect_location, alert: e.message)
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
