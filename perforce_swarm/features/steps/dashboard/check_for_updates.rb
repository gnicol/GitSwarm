class VersionCheck
  class << self
    attr_accessor :versions
  end
end

class Spinach::Features::CheckForUpdates < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include Gitlab::CurrentSettings

  step 'Set check for updates status to unknown' do
    ApplicationSetting.first.update(version_check_enabled: nil)
    current_application_settings.version_check_enabled = nil
  end

  step 'Check for updates status is unknown' do
    current_application_settings.version_check_enabled.should be_nil
  end

  step 'Check for updates is enabled' do
    ApplicationSetting.first.update(version_check_enabled: true)
    current_application_settings.version_check_enabled = true
  end

  step 'Disable check for updates' do
    ApplicationSetting.first.update(version_check_enabled: false)
    current_application_settings.version_check_enabled = false
  end

  step 'I click yes to allow check for updates' do
    page.click_link 'Yes'
  end

  step 'I click no to disable check for updates' do
    page.click_link 'No'
  end

  step 'Am behind the next major version of GitSwarm' do
    add_to_versions_list(incremented_version(major_increment: 1))
  end

  step 'Am behind the next minor version of GitSwarm' do
    add_to_versions_list(incremented_version(minor_increment: 1))
  end

  step 'Am behind the next build version of GitSwarm' do
    add_to_versions_list(incremented_version(build_increment: 1))
  end

  step 'The next version is a critical update' do
    versions = VersionCheck.versions
    latest   = VersionCheck.latest
    # mark the latest one as critical and modify in place
    versions.map! do |version|
      version['critical'] = true if version['version'] == latest
      version
    end

    # update the in-memory and cached versions
    VersionCheck.versions = versions
    Rails.cache.write(PerforceSwarm::VersionCheckSelf::VERSIONS_CACHE_KEY, versions)
  end

  step 'I should see a check for updates growl' do
    page.should have_selector '.version-check-status'
  end

  step 'I should not see a check for updates growl' do
    page.should_not have_selector '.version-check-status'
  end

  step 'I should be notified that my version is out of date' do
    page.should have_content 'This Installation of GitSwarm is out of date.'
  end

  step 'I should be notified of a critical update' do
    page.should have_content 'A critical update is available.'
  end

  step 'Version check enabled checkbox is checked' do
    find('input[type=checkbox][name="application_setting[version_check_enabled]"]').should be_checked
  end

  step 'Version check enabled checkbox is not checked' do
    find('input[type=checkbox][name="application_setting[version_check_enabled]"]').should_not be_checked
  end

  step 'I should see application settings saved' do
    page.should have_content 'Application settings saved successfully'
  end

  step 'I should be asked if I want to ignore this update' do
    page.should have_content "Don't show again for this version"
  end

  step 'I should be prompted to enable or disable check for updates' do
    page.should have_content 'Allow GitSwarm to keep checking for updates?'
  end

  def add_to_versions_list(version, critical: nil, more_info: nil, platform: nil)
    cached = Rails.cache.fetch(PerforceSwarm::VersionCheckSelf::VERSIONS_CACHE_KEY)

    # delete it if we've already got it
    cached.delete_if { |v| v['version'] == version }

    new_version = { 'version' => version }
    /(?<major>\d+)\.(?<minor>\d+)\-(?<build>.+)/ =~ version
    new_version['major']     = major
    new_version['minor']     = minor
    new_version['build']     = build if build
    new_version['platform']  = platform ? platform : VersionCheck.platform
    new_version['critical']  = true if critical
    new_version['more_info'] = more_info if more_info

    # add back to the cache
    cached.push(new_version)
    Rails.cache.write(PerforceSwarm::VersionCheckSelf::VERSIONS_CACHE_KEY, cached)

    # update the in-memory object
    VersionCheck.versions = cached
  end

  def incremented_version(major_increment: 0, minor_increment: 0, build_increment: 0)
    /(?<major>\d+)\.(?<minor>\d+)(\-(?<build>.+))?/ =~ PerforceSwarm::VERSION
    major = major.to_i + major_increment
    minor = minor.to_i + minor_increment
    build = build ? version_as_number(build) + build_increment : build_increment + 1
    "#{major}.#{minor}-#{build}"
  end

  def version_as_number(str)
    return -2 if str == 'alpha'
    return -1 if str == 'beta'
    str.to_i
  end
end
