require_relative '../../spec_helper'

describe 'PerforceSwarm::VersionCheck', no_db: true do
  before do
    versions = %w(2015.1-beta 2015.1-1 2015.1 2015.1-2 2015.2-beta 2015.2-1 2015.5-alpha 2016.1-1)
    versions.each do |version|
      name = '@v' + version.gsub(/[-.]/, '_')
      instance_variable_set(name.to_sym, VersionCheck.parse_version(version))
    end
  end

  context '>' do
    it { expect(@v2015_1_beta).to be < @v2015_1_1 }
  end

  context '<' do
    it { expect(@v2015_1).to be < @v2015_1_1 }
  end

  context '==' do
    it { expect(@v2015_1).to be == VersionCheck.parse_version('2015-1') }
  end
end
