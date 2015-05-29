require Rails.root.join('app', 'controllers', 'admin', 'application_settings_controller')

module PerforceSwarm
  module AdminApplicationSettingsControllerExtension
    def application_setting_params
      super
      params.require(:application_setting).permit(:last_version_ignored)
    end
  end
end

class Admin::ApplicationSettingsController < Admin::ApplicationController
  prepend PerforceSwarm::AdminApplicationSettingsControllerExtension
end
