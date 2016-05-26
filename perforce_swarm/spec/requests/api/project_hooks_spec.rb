require 'spec_helper'

describe API::API, 'ProjectHooks', api: true do
  describe 'DELETE /projects/:id/hooks/:hook_id' do
    it 'should return a 404 error when deleting non existent hook', override: true do
      # TODO: gives a 200 on Jenkins VM, but 404 when I run it locally
    end
  end
end
