require_relative '../spec_helper'

describe ApplicationHelper do
  describe 'current_route?' do
    before do
      controller.stub(:controller_name).and_return('foo')
      allow(self).to receive(:action_name).and_return('foo')
    end

    it 'returns true when route matches argument' do
      current_route?('foo#foo').should be_true
    end

    it 'returns false when controller does not match arguement' do
      current_route?('bar#foo').should_not be_true
    end

    it 'returns false when action does not match argument' do
      current_route?('foo#bar').should_not be_true
    end
  end
end
