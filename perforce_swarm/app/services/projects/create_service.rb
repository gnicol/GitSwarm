require Rails.root.join('app', 'services', 'projects', 'create_service')

module PerforceSwarm
  module CreateServiceExtensions
    def execute
      # Check that you have access to the repo you are importing
      if params[:git_fusion_mirrored] && params[:git_fusion_import_type] == 'repo-import'
        repos = []
        error = nil
        begin
          PerforceSwarm::GitFusionRepo.list(params[:git_fusion_entry], current_user.username).each_key do |repo_name|
            repos << "mirror://#{params[:git_fusion_entry]}/#{repo_name}"
          end
        rescue => e
          error = e.message
        end
        if error || !repos.include?(params[:git_fusion_repo])
          @project = Project.new(params)
          if error
            @project.errors.add(:base, error)
          else
            @project.errors.add(:git_fusion_repo_name, 'is not valid')
          end
          return @project
        end
      end
      super
    end

    def after_create_actions
      super

      # user has chosen to import via Git Fusion, so start the import process
      @project.import_start if @project.git_fusion_mirrored?
    end
  end
end

class Projects::CreateService
  prepend PerforceSwarm::CreateServiceExtensions
end
