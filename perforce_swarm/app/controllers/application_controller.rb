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

    def load_recent_projects
      if current_user
        @recent_projects = current_user.authorized_projects
          .reorder('last_activity_at DESC, created_at DESC').non_archived.limit(5)
      end
    end

    # Ensure our engine's 404 page gets rendered
    def render_404
      render file: Rails.root.join('perforce_swarm', 'public', '404'), layout: false, status: '404'
    end

    def load_user_projects
      # Pass a list of project id's that user is allowed to see
      # to use in frontend for localStorage verification
      projects = []
      if current_user
        current_user.projects_sorted_by_activity.each do |project|
          projects.push(project.id)
        end
      end
      render json: projects
    end
  end
end

class ApplicationController < ActionController::Base
  prepend PerforceSwarm::ApplicationControllerExtension
  before_filter :load_recent_projects
end
