require_relative '../../spec_helper'

# add the ability to tweak the versions directly - this is not something we want to expose normally, of course
class VersionCheck
  class << self
    attr_accessor :versions
  end
end

describe 'PerforceSwarm::VersionCheck', no_db: true do
  def create_version(version_string, options = {})
    options['platform']  ||= VersionCheck.platform
    options['more_info'] ||= nil
    options['critical']  ||= nil
    version = { 'version' => version_string }
    /(?<major>\d+)\.(?<minor>\d+)(?<build>.+)/ =~ version_string
    version['major'] = major
    version['minor'] = minor
    version['build'] = build[1..-1] if build
    version.merge(options)
  end

  def create_version_check(versions, with_version)
    stub_const('PerforceSwarm::VERSION', with_version)
    version_check = VersionCheck.clone
    version_check.versions = versions.collect do |v|
      v.is_a?(Hash) ? create_version(v['version'], v) : create_version(v)
    end
    version_check
  end

  shared_examples :up_to_date do |versions, with_version|
    it 'has no update details' do
      version_check = create_version_check(versions, with_version)
      expect(version_check.update_details).to be nil
    end
  end

  shared_examples :outdated do |versions, with_version, expected_latest|
    it 'is outdated' do
      version_check = create_version_check(versions, with_version)
      expect(version_check.update_details).to_not be nil
      expect(version_check.latest).to eq(expected_latest)
      expect(version_check.outdated?).to be_truthy
    end
  end

  shared_examples :critical do |versions, with_version|
    it 'is marked as critical' do
      version_check = create_version_check(versions, with_version)
      expect(version_check.critical?).to be_truthy
    end
  end

  shared_examples :more_info do |versions, with_version|
    it 'has a more_info link' do
      version_check = create_version_check(versions, with_version)
      expect(version_check.more_info).to_not be nil
    end
  end

  context 'with empty versions' do
    include_examples :up_to_date, [], '2015.1-1'
  end

  context 'with current version installed' do
    include_examples :up_to_date, [PerforceSwarm::VERSION], PerforceSwarm::VERSION
  end

  context 'with updated build available' do
    include_examples :outdated, ['2015.1-2'], '2015.1-1', '2015.1-2'
  end

  context 'with updated minor version available' do
    include_examples :outdated, ['2015.2-1'], '2015.1-1', '2015.2-1'
  end

  context 'with updated major version available' do
    include_examples :outdated, ['2016.1'], '2015.1-1', '2016.1'
  end

  context 'with no available versions' do
    include_examples :up_to_date, [''], '2015.1-1'
    include_examples :up_to_date, ['asdasd'], '2015.1-1'
  end

  context 'with critical update available' do
    versions = [{ 'version' => '2015.1-2', 'critical' => true }]
    include_examples :outdated, versions, '2015.1-1', '2015.1-2'
    include_examples :critical, versions, '2015.1-1', '2015.1-2'
  end

  context 'with critical intermediary update available' do
    versions = [{ 'version' => '2015.1-2', 'critical' => true }, '2015.2-1']
    include_examples :outdated, versions, '2015.1-1', '2015.2-1'
    include_examples :critical, versions, '2015.1-1', '2015.2-1'
  end

  context 'with update that has more info available' do
    versions = ['2015.1-1', { 'version' => '2015.2-1', 'more_info' => 'http://foo.com' }]
    include_examples :outdated, versions, '2015.1-1', '2015.2-1'
    include_examples :more_info, versions, '2015.1-1', '2015.2-1'
  end
end
