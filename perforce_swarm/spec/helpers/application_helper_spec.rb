require_relative '../spec_helper'

describe ApplicationHelper do
  let(:promo_host_value) { 'perforce.com' }
  let(:promo_url_value) { 'http://' + promo_host_value }

  describe 'current_route?' do
    before do
      allow(controller).to receive(:controller_name).and_return('foo')
      allow(self).to receive(:action_name).and_return('foo')
    end

    it 'returns true when route matches argument' do
      expect(current_route?('foo#foo')).to be true
    end

    it 'returns false when controller does not match argument' do
      expect(current_route?('bar#foo')).to_not be true
    end

    it 'returns false when action does not match argument' do
      expect(current_route?('foo#bar')).to_not be true
    end
  end

  describe 'promo_host' do
    it 'returns perforce.com always' do
      expect(promo_host).to eq(promo_host_value)
    end
  end

  describe 'promo_url' do
    it 'returns http://perforce.com always' do
      expect(promo_url).to eq(promo_url_value)
    end
  end
end
