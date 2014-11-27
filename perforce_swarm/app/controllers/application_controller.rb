require Rails.root.join('app', 'controllers', 'application_controller')

module PerforceSwarm
  module ApplicationControllerExtension
    def add_gon_variables
      super

      # Pass the visibility level constants to the frontend
      gon.visibility_levels = Gitlab::VisibilityLevel.options

      # Pass additional user information to the frontend for
      # creating routes and determining which menus to show
      if current_user
        gon.current_user_username = current_user.username
      end
    end

    def load_recent_projects
      if current_user
        @recent_projects = current_user.authorized_projects.sorted_by_activity.non_archived.limit(5)
      end
    end
  end
end

class ApplicationController < ActionController::Base
  prepend PerforceSwarm::ApplicationControllerExtension
  before_filter :load_recent_projects
end
