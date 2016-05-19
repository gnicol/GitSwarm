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

  describe 'project title' do
    let(:user) { create(:user) }
    let(:project) { create(:project, namespace: user.namespace) }
    let(:project2) { create(:project, namespace: user.namespace, path: 'test') }
    let(:issue) { create(:issue, project: project) }

    context 'on issues page', js: true do
      before do
        login_with(user)
        project.team.add_user(user, Gitlab::Access::MASTER)
        project2.team.add_user(user, Gitlab::Access::MASTER)
        visit namespace_project_issue_path(project.namespace, project, issue)
      end

      it 'click toggle and show dropdown', override: true do
        # TODO: Implement
        expect(page).to have_css('.js-projects-dropdown-toggle')
        expect(page).to have_content project.name
      end
    end
  end
end
