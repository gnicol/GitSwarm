require Rails.root.join('app', 'helpers', 'version_check_helper')

module VersionCheckHelper
  def show_version_check?
    # only admins who haven't dismissed the header get to see it
    return false unless current_user.admin? && cookies[:dismiss_version_check].nil?

    # always try and show it if they haven't picked
    return true if current_application_settings.version_check_enabled.nil?

    # never show it if they have the feature disabled
    return false unless current_application_settings.version_check_enabled

    # if we're outdated and this particular update isn't ignored; show it!
    VersionCheck.outdated? && VersionCheck.latest != current_application_settings.last_version_ignored
  end
end
