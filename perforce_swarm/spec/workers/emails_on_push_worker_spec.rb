require 'spec_helper'

describe EmailsOnPushWorker do
  describe '#perform' do
    context 'when there are multiple recipients' do
      it 'only generates the mail once', override: true do
        # TODO: Intermittent failure
      end
    end
  end
end
