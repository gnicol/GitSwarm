# This is an override test, so use the parent spec_helper
require 'rails_helper'

describe 'help/index' do
  describe 'version information' do
    it 'is hidden from guests', override: true do
      true
    end
  end
end
