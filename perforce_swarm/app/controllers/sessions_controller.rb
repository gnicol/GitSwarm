require Rails.root.join('app', 'controllers', 'sessions_controller')

module PerforceSwarm
  module SessionsControllerExtension
    def create
      super
      current_user.clear_git_fusion_repo_cache if current_user
    end
  end
end

class SessionsController < Devise::SessionsController
  prepend PerforceSwarm::SessionsControllerExtension
end