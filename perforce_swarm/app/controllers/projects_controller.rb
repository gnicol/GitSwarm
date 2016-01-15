require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def configure_helix_mirroring
      render 'perforce_swarm/git_fusion/projects/helix_mirroring', layout: 'project_settings'
    end

    # actually performs the task of mirroring on the specified project and repo server
    def enable_helix_mirroring
      fail 'No project specified.' unless @project
      fail 'Project is already mirrored in Helix.' if @project.git_fusion_mirrored?
      fail 'This project is already associated to a Helix Git Fusion repository.' if @project.git_fusion_repo.present?

      # create the p4gf_config file, which creates the repo in Git Fusion
      fusion_server = params['fusion_server']
      fail 'No Git Fusion server specified.' unless fusion_server
      repo_creator  = PerforceSwarm::GitFusion::RepoCreator.new(fusion_server, @project.namespace.name, @project.path)
      repo_creator.save
      PerforceSwarm::GitFusion::RepoAccess.clear_cache(server: fusion_server)

      # enable mirroring on the project and create the mirror remote
      @project.enable_git_fusion_mirroring!(fusion_server, repo_creator.repo_name)

      # kick off and background initial push
      push_job = fork do
        gitlab_shell  = File.expand_path(Gitlab.config.gitlab_shell.path)
        mirror_script = File.join(gitlab_shell, 'perforce_swarm', 'bin', 'gitswarm-mirror')
        exec Shellwords.shelljoin([mirror_script, 'push', @project.path_with_namespace + '.git'])
      end
      Process.detach(push_job)
      redirect_to(project_path(@project), notice: 'Helix mirroring successful!')
    rescue => e

      # any errors occurring in the above are shown on the configure mirroring page, but if we've
      # gotten as far as mirroring, this will cause a double redirect, so we hit the project details page instead
      redirect_location = @project && @project.git_fusion_mirrored? ? project_path(@project) : :back
      redirect_to(redirect_location, alert: e.message)
    end

    def disable_helix_mirroring
      fail 'No project specified.' unless @project
      fail 'Project is not mirrored in Helix.' unless @project.git_fusion_mirrored?

      # disable mirroring in GitSwarm, and redirect to project details page
      @project.disable_git_fusion_mirroring!
      redirect_to(project_path(@project), notice: 'Helix mirroring successfully disabled!')
    rescue => e
      redirect_to(project_path(@project), alert: e.message)
    end

    def project_params
      params[:git_fusion_auto_create] = param_from_string(params[:git_fusion_auto_create])

      # if we were given git fusion parameters, incorporate those now
      if params[:git_fusion_entry] && !params[:git_fusion_entry].blank? &&
         params[:git_fusion_repo_name] && params[:git_fusion_auto_create] == false
        params[:git_fusion_repo]     = "mirror://#{params[:git_fusion_entry]}/#{params[:git_fusion_repo_name]}"
        params[:git_fusion_mirrored] = true
      end

      super.merge(params.permit(:git_fusion_repo, :git_fusion_auto_create,
                                :git_fusion_entry, :git_fusion_mirrored))
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
