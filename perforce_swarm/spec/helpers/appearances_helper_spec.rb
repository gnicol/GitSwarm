require_relative '../spec_helper'

describe AppearancesHelper do
  describe 'brand_title' do
    it 'returns GitSwarm always' do
      expect(brand_title).to eq(AppearancesHelper::BRAND_TITLE_VALUE)
    end
  end
end
