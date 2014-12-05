require Rails.root.join('app', 'controllers', 'projects', 'application_controller')

class Projects::ApplicationController < ApplicationController
  prepend PerforceSwarm::ProjectsControllerHelper
  before_filter :add_project_gon_variables
end
