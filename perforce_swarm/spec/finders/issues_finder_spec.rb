require 'spec_helper'

describe IssuesFinder do
  let(:user) { create(:user) }

  describe '#execute' do
    let(:search_user) { user }
    let(:issues) { IssuesFinder.new(search_user, params.merge(scope: scope, state: 'opened')).execute }

    context 'scope: all' do
      let(:scope) { 'all' }

      context 'filtering by upcoming milestone', override: true do
        let(:params) { { milestone_title: Milestone::Upcoming.name } }

        let(:project_no_upcoming_milestones) { create(:empty_project, :public) }
        let(:project_next_1_1) { create(:empty_project, :public) }
        let(:project_next_8_8) { create(:empty_project, :public) }

        # note that we override Date.today to Date.current which respects timezones
        # if we don't, this test will fail due to the discrepancy between UTC and local time
        let(:yesterday) { Date.current - 1.day }
        let(:tomorrow) { Date.current + 1.day }
        let(:two_days_from_now) { Date.current + 2.days }
        let(:ten_days_from_now) { Date.current + 10.days }

        let(:milestones) do
          [
            create(:milestone, :closed, project: project_no_upcoming_milestones),
            create(:milestone, project: project_next_1_1, title: '1.1', due_date: two_days_from_now),
            create(:milestone, project: project_next_1_1, title: '8.8', due_date: ten_days_from_now),
            create(:milestone, project: project_next_8_8, title: '1.1', due_date: yesterday),
            create(:milestone, project: project_next_8_8, title: '8.8', due_date: tomorrow)
          ]
        end

        before do
          milestones.each do |milestone|
            create(:issue, project: milestone.project, milestone: milestone, author: user, assignee: user)
          end
        end

        it 'returns issues in the upcoming milestone for each project' do
          expect(issues.map { |issue| issue.milestone.title }).to contain_exactly('1.1', '8.8')
          expect(issues.map { |issue| issue.milestone.due_date }).to contain_exactly(tomorrow, two_days_from_now)
        end
      end
    end
  end
end
