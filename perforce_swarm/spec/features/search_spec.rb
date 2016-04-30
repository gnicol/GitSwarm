require 'spec_helper'

describe 'Search', feature: true do
  let(:user) { create(:user) }
  let(:project) { create(:project, namespace: user.namespace) }

  before do
    login_with(user)
    project.team << [user, :reporter]
    visit search_path
  end

  it 'top right search form is not present', override: true do
    expect(page).to have_selector('.search')
  end
end
