require Rails.root.join('app', 'helpers', 'version_check_helper')

module VersionCheckHelper
  def version_check_enabled
    current_application_settings.version_check_enabled.nil? || current_application_settings.version_check_enabled
  end

  def version_check_ignored(latest)
    current_application_settings.last_version_ignored &&
    (latest == Gem::Version.new(current_application_settings.last_version_ignored))
  end

  def version_check_notification
    version_check = VersionCheck.new
    unless version_check.status == VersionCheck::VERSION_UNKNOWN || version_check_ignored(version_check.latest)
      render('shared/version_check',
        version_check: version_check
      )
    end
  end

  def version_check_enabled_link(enabled)
    anchor = enabled ? 'Yes' : 'No'
    link_to anchor, admin_application_setting_service_path(application_setting: {version_check_enable: enabled}), remote: true, method: :put, class: 'alert-link'
  end
end
