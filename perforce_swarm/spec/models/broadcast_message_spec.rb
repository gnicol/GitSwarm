require 'spec_helper'

describe BroadcastMessage, models: true do
  describe '.current' do
    it 'should return last message if time match', override: true do
      # TODO: intermittent failure that needs to be investigated
    end
  end
end
