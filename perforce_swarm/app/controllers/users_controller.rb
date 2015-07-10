require Rails.root.join('app', 'controllers', 'users_controller')

module PerforceSwarm
  module UsersControllerExtension
    def load_recent_projects
      projects = []
      if current_user
        recent = current_user.projects_sorted_by_activity.limit(5)
        recent.each do |project|
          projects.push(project.id)
        end
      end
      render json: projects
    end
  end
end

class UsersController < ApplicationController
  prepend PerforceSwarm::UsersControllerExtension
end
