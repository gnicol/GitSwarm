require Rails.root.join('app', 'controllers', 'sessions_controller')

module PerforceSwarm
  module SessionsControllerExtension
    def create
      super
      GitFusion::RepoAccessCache.clear_cache(current_user.username) if current_user
    end
  end
end

class SessionsController < Devise::SessionsController
  prepend PerforceSwarm::SessionsControllerExtension
end
