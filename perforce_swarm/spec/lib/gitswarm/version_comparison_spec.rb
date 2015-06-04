require_relative '../../spec_helper'

describe 'PerforceSwarm::VersionCheck Version Comparison', no_db: true do
  before do
    versions = %w(2015.1-beta 2015.1-1 2015.1 2015.1-2 2015.2-beta 2015.2-1 2015.5-alpha 2016.1-1)
    versions.each do |version|
      name = '@v' + version.gsub(/[-.]/, '_')
      instance_variable_set(name.to_sym, VersionCheck.parse_version(version))
    end
  end

  context '>' do
    it { expect(@v2015_1_beta).to be < @v2015_1_1 }
    it { expect(@v2015_1_1).to be < @v2015_1_2 }
    it { expect(@v2015_1_1).to be < @v2015_5_alpha }
    it { expect(@v2015_1).to be < @v2016_1_1 }
    it { expect(@v2015_2_beta).to be < @v2016_1_1 }
  end

  context '<' do
    it { expect(@v2015_1_beta).to be < @v2015_1_1 }
    it { expect(@v2015_1_beta).to be < @v2015_1 }
    it { expect(@v2015_1).to be < @v2015_1_1 }
    it { expect(@v2015_2_1).to be < @v2016_1_1 }
    it { expect(@v2015_5_alpha).to be < @v2016_1_1 }
  end

  context '==' do
    it { expect(@v2015_1).to be == VersionCheck.parse_version('2015.1-0') }
  end

  context 'valid version checks' do
    it { expect(VersionCheck.valid_version?('')).to be_falsey }
    it { expect(VersionCheck.valid_version?('lasldkasldkad')).to be_falsey }
    it { expect(VersionCheck.valid_version?('-0')).to be_falsey }
    it { expect(VersionCheck.valid_version?('2015.1')).to be_truthy }
    it { expect(VersionCheck.valid_version?('2015.1-beta')).to be_truthy }
  end
end
