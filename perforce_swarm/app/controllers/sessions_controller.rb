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
  protect_from_forgery except: [:create]
  prepend PerforceSwarm::SessionsControllerExtension
end
