require Rails.root.join('app', 'services', 'projects', 'create_service')

module PerforceSwarm
  module CreateServiceExtensions
    def after_create_actions
      super

      # user has chosen to import via Git Fusion, so start the import process
      @project.import_start if @project.git_fusion_import?
    end
  end
end

class Projects::CreateService
  prepend PerforceSwarm::CreateServiceExtensions
end
