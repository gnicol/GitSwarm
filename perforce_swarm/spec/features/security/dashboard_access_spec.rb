# This is an override test, so use the parent spec_helper
require 'spec_helper'

describe 'Dashboard access', feature: true  do
  describe 'GET /help', override: true do
    subject { help_path }

    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_allowed_for :visitor }
  end
end
