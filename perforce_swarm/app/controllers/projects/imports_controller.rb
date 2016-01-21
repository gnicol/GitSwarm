require Rails.root.join('app', 'controllers', 'projects', 'imports_controller')

module PerforceSwarm
  module ProjectsImportsControllerExtension
    def show
      super unless @project.git_fusion_mirrored? && @project.import_in_progress?
    end
  end
end

class Projects::ImportsController < Projects::ApplicationController
  prepend PerforceSwarm::ProjectsImportsControllerExtension
end
