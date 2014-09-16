require Rails.root.join('app', 'controllers', 'application_controller')

module PerforceSwarm
  module ApplicationControllerExtension
    def add_gon_variables
      super

      # Pass additional user information to the frontend for
      # creating routes and determining which menus to show
      if current_user
        gon.current_user_username = current_user.username
        gon.current_user_is_admin = current_user.is_admin?
      end
    end
  end

  module ApplicationControllerIncludes
    def load_recent_projects
      if current_user
        @recent_projects = current_user.authorized_projects.sorted_by_activity.non_archived.limit(5)
      end
    end
  end
end

class ApplicationController < ActionController::Base
  prepend PerforceSwarm::ApplicationControllerExtension
  include PerforceSwarm::ApplicationControllerIncludes
end
