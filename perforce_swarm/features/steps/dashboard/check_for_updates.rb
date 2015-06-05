class Spinach::Features::CheckForUpdates < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include Gitlab::CurrentSettings

  step 'Set check for updates status to unknown' do
    ApplicationSetting.first.update(version_check_enabled: nil)
    current_application_settings.version_check_enabled = nil
  end

  step 'I should see a check for updates growl' do
    page.should have_selector '.version-check-status'
  end

  step 'I should not see a check for updates growl' do
    page.should_not have_selector '.version-check-status'
  end

  step 'I should be prompted to enable or disable check for updates' do
    page.should have_content 'Allow GitSwarm to keep checking for updates?'
  end
end
