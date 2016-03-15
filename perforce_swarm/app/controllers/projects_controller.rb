require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def configure_helix_mirroring
      check_helix_mirroring_permissions
      render 'perforce_swarm/git_fusion/projects/helix_mirroring', layout: 'project_settings'
    rescue => e
      redirect_to(project_path(@project), alert: e.message)
    end

    # actually performs the task of mirroring on the specified project and repo server
    def enable_helix_mirroring
      fail 'No project specified.' unless @project
      check_helix_mirroring_permissions
      fail 'Project is already mirrored in Helix.' if @project.git_fusion_mirrored?
      fail 'This project is already associated to a Helix Git Fusion repository.' if @project.git_fusion_repo.present?

      # create the p4gf_config file, which creates the repo in Git Fusion
      fusion_server = params['fusion_server']
      fail 'No Git Fusion server specified.' unless fusion_server
      repo_creator = PerforceSwarm::GitFusion::AutoCreateRepoCreator.new(fusion_server)
      repo_creator.namespace(@project.namespace.name).project_path(@project.path).save
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
      logger.info("Helix Mirroring enable started on project '#{@project.name_with_namespace}' " \
                  "by user '#{current_user.username}'")
      redirect_to(project_path(@project), notice: 'Helix mirroring successful!')
    rescue => e
      # any errors occurring in the above are shown on the configure mirroring page, but if we've
      # gotten as far as mirroring, this will cause a double redirect, so we hit the project details page instead
      redirect_location = @project && @project.git_fusion_mirrored? ? project_path(@project) : :back
      redirect_to(redirect_location, alert: e.message)
    end

    def disable_helix_mirroring
      fail 'No project specified.' unless @project
      check_helix_mirroring_permissions
      fail 'Project is not mirrored in Helix.' unless @project.git_fusion_mirrored?

      # disable mirroring in GitSwarm, log, and redirect to project details page
      @project.disable_git_fusion_mirroring!
      logger.info("Helix Mirroring disabled on project '#{@project.name_with_namespace}' " \
                  "by user '#{current_user.username}'")
      redirect_to(project_path(@project), notice: 'Helix mirroring successfully disabled!')
    rescue => e
      redirect_to(project_path(@project), alert: e.message)
    end

    def project_params
      # if we were given git fusion parameters, incorporate those now
      if params[:git_fusion_entry] && !params[:git_fusion_entry].blank? &&
          params[:git_fusion_repo_name] &&
          params[:git_fusion_repo_create_type] == Project::GIT_FUSION_REPO_CREATION_IMPORT_REPO
        params[:git_fusion_repo]     = "mirror://#{params[:git_fusion_entry]}/#{params[:git_fusion_repo_name]}"
        params[:git_fusion_mirrored] = true
      end

      # Sanitize branch names
      if params[:git_fusion_branch_mappings]
        # Create a new hash of branch mappings with sanitized branch names
        branch_mappings = {}
        params[:git_fusion_branch_mappings].each do |branch_name, path|
          # Do the same santization as GitLab's branch create action.
          # strip_tags removes tags, but keeps their content, sanitize will clean
          # up the remaining sneakier techniques of using ascii, hex, unicode
          # characters to get html into the input.
          sanitized_name                  = sanitize(strip_tags(branch_name.dup))
          branch_mappings[sanitized_name] = path
        end
        params[:git_fusion_branch_mappings] = branch_mappings
        params[:git_fusion_default_branch]  = sanitize(strip_tags(params[:git_fusion_default_branch]))
      end

      branches = (params[:git_fusion_branch_mappings] || {}).keys
      super.merge(params.permit(:git_fusion_repo, :git_fusion_repo_create_type,
                                :git_fusion_entry, :git_fusion_mirrored,
                                :git_fusion_default_branch, git_fusion_branch_mappings: branches))
    end

    protected

    def check_helix_mirroring_permissions
      # ensure that we have a logged-in user, and that they have permission to re-enable the project
      if !current_user || !current_user.can?(:admin_project, @project)
        fail 'You do not have permissions to view or modify Helix mirroring settings on this project.'
      end
    end
  end
end

class ProjectsController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerExtension
  prepend PerforceSwarm::ProjectsControllerHelper
  include ActionView::Helpers::SanitizeHelper
  before_filter :add_project_gon_variables
end
