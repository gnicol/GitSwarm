require Rails.root.join('app', 'controllers', 'application_controller')

module PerforceSwarm
  module ApplicationControllerExtension
    def add_gon_variables
      super

      # Pass the visibility level constants to the frontend
      gon.visibility_levels = Gitlab::VisibilityLevel.options

      # Pass additional user information to the frontend for
      # creating routes and determining which menus to show
      gon.current_user_username = current_user.username if current_user
    end

    # Ensure our engine's 404 page gets rendered
    def render_404
      render file: Rails.root.join('perforce_swarm', 'public', '404'), layout: false, status: '404'
    end
  end
end

class ApplicationController < ActionController::Base
  prepend PerforceSwarm::ApplicationControllerExtension
end
