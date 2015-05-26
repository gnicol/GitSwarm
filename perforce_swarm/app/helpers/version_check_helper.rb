require Rails.root.join('app', 'helpers', 'version_check_helper')

module VersionCheckHelper
  def version_check_enabled
    current_application_settings.version_check_enabled.nil? || current_application_settings.version_check_enabled
  end

  def version_check_notification
    version_check = VersionCheck.new
    # @TODO: Check whether the user has already asked to not be bothered for the latest version
    unless version_check.status == VersionCheck::VERSION_UNKNOWN
      render('shared/version_check',
        status: version_check.status,
        more_info: version_check.more_info,
        check_enabled: current_application_settings.version_check_enabled
      )
    end
  end
end
