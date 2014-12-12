module PerforceSwarm
  module ProjectsControllerHelper
    def add_project_gon_variables
      # Pass the current project to the frontend
      gon.project = view_context.projects_as_simple_json(@project) if @project
    end
  end
end
