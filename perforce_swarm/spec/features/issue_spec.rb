require_relative '../spec_helper'

describe 'Issues', js: true, feature: true do
  let(:project) { create(:project) }

  before do
    login_as :user
    project.team << [@user, :developer]
  end

  describe 'Update a single issue page' do
    let(:issue) { create(:issue, project: project, author: @user, description: 'Bug in feature.') }

    before do
      visit namespace_project_issue_path(project.namespace, project, issue)
    end

    context 'Post a comment' do
      before do
        within('.js-main-target-form') do
          fill_in 'note[note]', with: 'Adding a comment in this issue.'
          click_button 'Add Comment'
        end
      end

      it 'should show the comment in the comment field' do
        find(:css, '.notes').should have_content('Adding a comment in this issue.')
      end
    end
  end
end
