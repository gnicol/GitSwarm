require Rails.root.join('app', 'controllers', 'projects_controller')

class ProjectsController < ApplicationController
  before_filter :load_recent_projects, except: [:new, :create]
end
