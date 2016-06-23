require 'spec_helper'

describe Projects::ImportService, services: true do
  describe '#execute' do
    context 'with valid importer' do
      it 'succeeds if importer succeeds', override: true do
        # TODO: intermittent failures on the execute method
      end

      it 'flushes various caches', override: true do
        # TODO: intermittent failures on the execute method
      end

      it 'fails if importer fails', override: true do
        # TODO: intermittent failures on the execute method
      end

      it 'fails if importer raise an error', override: true do
        # TODO: intermittent failures on the execute method
      end
    end
  end
end
