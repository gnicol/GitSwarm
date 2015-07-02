require Rails.root.join('app', 'controllers', 'admin', 'application_settings_controller')

module PerforceSwarm
  module AdminApplicationSettingsControllerExtension
    def application_setting_params
      super.merge(params.require(:application_setting).permit(:last_version_ignored))
    end

    def update
      # overwrite the update function to remove the redirect on success - instead just render page
      # this enables an ajax call to settings update, and returns a flash notice
      if @application_setting.update_attributes(application_setting_params)
        flash.now[:notice] = 'Application settings saved successfully'
      end
      render :show
    end
  end
end

class Admin::ApplicationSettingsController < Admin::ApplicationController
  prepend PerforceSwarm::AdminApplicationSettingsControllerExtension
end
