require_relative '../../spec_helper'

# add the ability to tweak the versions directly - this is not something we want to expose normally, of course
class VersionCheck
  attr_writer :versions
end

def create_version(version_string, platform: VersionCheck.platform, more_info: nil, critical: nil)
  version = { version: version_string }
  /(?<major>\d+)\.(?<minor>\d+)(?<build>.+)/ =~ version_string
  version['major'] = major
  version['minor'] = minor
  version['build'] = build[1..-1] if build
  version['platform'] = platform
  version['more_info'] = more_info if more_info
  version['critical'] = critical if critical
  version
end

# we need to compare to the defaults more than once, so factor out into a re-usable example
RSpec.shared_examples 'version_check_defaults' do |version_check|
  it 'returns defaults' do
    expect(version_check.update_details).to be nil
    expect(version_check.more_info).to be false
    expect(version_check.critical?).to be false
    expect(version_check.outdated?).to be false
    expect(version_check.latest).to eq(PerforceSwarm::VERSION)
  end
end

describe 'PerforceSwarm::VersionCheck', no_db: true do
  context 'with empty versions' do
    version_check = VersionCheck.clone
    version_check.versions.clear
    include_examples 'version_check_defaults', version_check
  end

  context 'with current version installed' do
    version_check = VersionCheck.clone
    version_check.versions = [create_version(PerforceSwarm::VERSION)]
    include_examples 'version_check_defaults', version_check
  end
end
