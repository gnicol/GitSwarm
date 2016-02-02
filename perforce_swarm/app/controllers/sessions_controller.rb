require Rails.root.join('app', 'controllers', 'sessions_controller')

module PerforceSwarm
  module SessionsControllerExtension
    def create
      super
      GitFusion::RepoAccess.clear_cache(username: current_user.username) if current_user
    end
  end
end

class SessionsController < Devise::SessionsController
  prepend PerforceSwarm::SessionsControllerExtension
end
