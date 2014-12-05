require Rails.root.join('app', 'controllers', 'projects_controller')

class ProjectsController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerHelper
  before_filter :add_project_gon_variables
end
