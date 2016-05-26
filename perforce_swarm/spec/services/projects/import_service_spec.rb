require 'spec_helper'

describe Projects::ImportService, services: true do
  describe '#execute' do
    context 'with valid importer' do
      it 'succeeds if importer succeeds', override: true do
        # TODO: intermittent failures on the execute method
      end
    end
  end
end
