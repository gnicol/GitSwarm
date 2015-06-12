class VersionCheck
  class << self
    attr_accessor :versions, :platform
  end
end

class Spinach::Features::CheckForUpdates < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include Gitlab::CurrentSettings

  attr_accessor :original_platform, :original_version

  before do
    # save a copy of our platform file
    platform_file      = Rails.root.join('.platform')
    @original_platform = File.read(platform_file) if File.exist?(platform_file)

    # save a copy of the original version, so we can change the constant as needed
    @original_version  = PerforceSwarm::VERSION
  end

  after do
    # put our original values back
    platform_file = Rails.root.join('.platform')
    File.unlink(platform_file) if File.exist?(platform_file)
    File.write(platform_file, @original_platform) if @original_platform

    modify_version(@original_version)
  end

  step 'Check for updates is enabled' do
    version_check_enabled_flag(true)
  end

  step 'Check for updates is disabled' do
    version_check_enabled_flag(false)
  end

  step 'Set check for updates status to unknown' do
    version_check_enabled_flag(nil)
  end

  step 'Check for updates status is unknown' do
    current_application_settings.version_check_enabled.should be_nil
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

  step 'My GitSwarm install is ahead by a minor version' do
    modify_version(incremented_version(minor_increment: 1))
  end

  step 'The next version is a critical update' do
    with_versions do |version|
      version['critical'] = true if version['version'] == VersionCheck.latest
    end
  end

  step 'The next version has a more info link' do
    with_versions do |version|
      version['more_info'] = 'http://foo.bar.baz' if version['version'] == VersionCheck.latest
    end
  end

  step 'We have a noarch update available in the versions list' do
    # make all existing platforms non-matching
    with_versions do |version|
      version['platform'] = 'univac'
    end
    add_to_versions_list(incremented_version(minor_increment: 1), platform: 'noarch')
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

  step 'I should see a more info link in the growl' do
    page.should have_link 'more info'
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

  step 'VersionCheck is set to an unsupported platform' do
    File.write(Rails.root.join('.platform'), 'pdp-11')
    VersionCheck.platform = 'pdp-11'
  end

  step 'VersionCheck has a platform of noarch' do
    File.write(Rails.root.join('.platform'), 'noarch')
    VersionCheck.platform = 'noarch'
  end

  step 'I enable check for updates and save the form' do
    check 'Version check enabled'
    click_button 'Save'
  end

  step 'I disable check for updates and save the form' do
    uncheck 'Version check enabled'
    click_button 'Save'
  end

  step 'My GitSwarm install is up to date' do
    with_versions do |version|
      version['version'] = PerforceSwarm::VERSION
    end
  end

  step 'I click the X to close the growl' do
    page.click_link 'X'
  end

  step 'There is no matching platform in the versions file' do
    with_versions do |version|
      version['platform'] = 'pdp-11'
    end
  end

  step 'There is a malformed version in the list of available versions' do
    with_versions do |version|
      version['version'] = 'c3p0'
    end
  end

  step 'The current version is a critical update' do
    with_versions do |version|
      version['critical'] = true if version['version'] == PerforceSwarm::VERSION
    end
  end

  step 'The dismiss_version_check cookie should be set' do
    # TODO: unable to access cookies - may require some driver tweaks
    # JIRA: https://jira.perforce.com:8443/browse/PGL-826
  end

  def modify_version(new_value)
    PerforceSwarm.send(:remove_const, :VERSION)
    PerforceSwarm.const_set(:VERSION, new_value)
  end

  def version_check_enabled_flag(value)
    ApplicationSetting.first.update(version_check_enabled: value)
    current_application_settings.version_check_enabled = value
  end

  def with_versions
    versions = VersionCheck.versions
    versions.map! do |version|
      yield(version)
      version
    end
    VersionCheck.versions = versions
    Rails.cache.write(PerforceSwarm::VersionCheckSelf::VERSIONS_CACHE_KEY, versions)
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
