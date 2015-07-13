require 'spec_helper'

describe Admin::UsersController do
  let(:admin)    { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'DELETE #user with projects' do
    let(:user) { create(:user) }
    let(:project) { create(:project, namespace: user.namespace) }

    before do
      project.team << [user, :developer]
    end

    it 'deletes user' do
      delete :destroy, id: user.username, format: :json
      expect(response.status).to eq(200)
      expect { User.find(user.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
