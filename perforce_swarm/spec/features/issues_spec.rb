require_relative '../spec_helper'

describe 'Issues', feature: true do
  include SortingHelper

  let(:project) { create(:project) }

  before do
    login_as :user
    user2 = create(:user)

    project.team << [[@user, user2], :developer]
  end

  describe 'filter issue' do
    titles = %w(foo bar baz)
    titles.each_with_index do |title, index|
      let!(title.to_sym) do
        create(:issue,
               title: title,
               project: project,
               created_at: Time.now - (index * 60))
      end
    end

    describe 'filtering by due date' do
      before do
        foo.update(due_date: 1.day.from_now)
        bar.update(due_date: 6.days.from_now)
      end

      # note that we override Date.today to Date.current which respects timezones
      # if we don't, this test will fail due to the discrepancy between UTC and local time
      it 'filters by overdue', override: true do
        foo.update(due_date: Date.current + 1.day)
        bar.update(due_date: Date.current + 20.days)
        baz.update(due_date: Date.current - 10.days)

        visit namespace_project_issues_path(project.namespace, project, due_date: Issue::Overdue.name)

        expect(page).not_to have_content('foo')
        expect(page).not_to have_content('bar')
        expect(page).to have_content('baz')
      end
    end
  end
end
