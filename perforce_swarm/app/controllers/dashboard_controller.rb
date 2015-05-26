require Rails.root.join('app', 'controllers', 'dashboard_controller')

module PerforceSwarm
  module DashboardControllerExtension
    alias_method :gitlab_show, :show
    def show
      
      gitlab_show
    end
  end
end

class DashboardController < Dashboard::ApplicationController
  prepend PerforceSwarm::DashboardControllerExtension
end
