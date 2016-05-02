require 'spec_helper'

feature 'Project', feature: true do
  describe 'project title' do
    include WaitForAjax

    let(:user)    { create(:user) }
    let(:project) { create(:project, namespace: user.namespace) }

    before do
      login_with(user)
      project.team.add_user(user, Gitlab::Access::MASTER)
      visit namespace_project_path(project.namespace, project)
    end

    it 'click toggle and show dropdown', js: true, override: true do
      # TODO: Implement
      expect(page).to have_css('.js-projects-dropdown-toggle')
    end
  end
end
