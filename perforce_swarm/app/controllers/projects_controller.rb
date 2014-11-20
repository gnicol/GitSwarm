require Rails.root.join('app', 'controllers', 'projects_controller')

module PerforceSwarm
  module ProjectsControllerExtension
    def add_project_gon_variables
      # Pass the current project to the frontend
      gon.project = view_context.projects_as_simple_json(@project) if @project
    end
  end
end

class ProjectsController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerExtension
  before_filter :add_project_gon_variables
end
