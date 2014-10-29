require 'spec_helper'

describe Gitlab::LDAP::Config do
  let(:config) { Gitlab::LDAP::Config.new provider }
  let(:provider) { 'ldap' }

  describe :initalize do
    it "works", :override => :true do
      expect(config).to be_a described_class
    end
  end
end
