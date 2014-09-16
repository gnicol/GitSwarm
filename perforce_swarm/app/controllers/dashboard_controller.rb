require Rails.root.join('app', 'controllers', 'dashboard_controller')

class DashboardController < ApplicationController
  before_filter :load_recent_projects
end
