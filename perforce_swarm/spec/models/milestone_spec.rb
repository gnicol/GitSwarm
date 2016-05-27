require 'spec_helper'

describe Milestone, models: true do
  let(:milestone) { create(:milestone) }
  let(:issue) { create(:issue) }
  let(:user) { create(:user) }

  describe :expired?, override: true do
    # note: replaced Date.today with Date.current, which respects timezone differences - if we don't,
    # the tests can fail depending on what time of day they are run
    context 'expired' do
      before do
        allow(milestone).to receive(:due_date).and_return(Date.current.prev_year)
      end

      it { expect(milestone.expired?).to be_truthy }
    end

    context 'not expired' do
      before do
        allow(milestone).to receive(:due_date).and_return(Date.current.next_year)
      end

      it { expect(milestone.expired?).to be_falsey }
    end
  end

  describe '.upcoming_ids_by_projects', override: true do
    let(:project_1) { create(:empty_project) }
    let(:project_2) { create(:empty_project) }
    let(:project_3) { create(:empty_project) }
    let(:projects) { [project_1, project_2, project_3] }

    # note: replaced Time.now with Time.current, which respects timezone differences - if we don't,
    # the tests can fail depending on what time of day they are run
    let!(:past_milestone_project_1) { create(:milestone, project: project_1, due_date: Time.current - 1.day) }
    let!(:current_milestone_project_1) { create(:milestone, project: project_1, due_date: Time.current + 1.day) }
    let!(:future_milestone_project_1) { create(:milestone, project: project_1, due_date: Time.current + 2.days) }

    let!(:past_milestone_project_2) { create(:milestone, project: project_2, due_date: Time.current - 1.day) }
    let!(:closed_milestone_project_2) do
      create(:milestone, :closed, project: project_2, due_date: Time.current + 1.day)
    end
    let!(:current_milestone_project_2) { create(:milestone, project: project_2, due_date: Time.current + 2.days) }

    let!(:past_milestone_project_3) { create(:milestone, project: project_3, due_date: Time.current - 1.day) }

    # The call to `#try` is because this returns a relation with a Postgres DB,
    # and an array of IDs with a MySQL DB.
    let(:milestone_ids) { Milestone.upcoming_ids_by_projects(projects).map { |id| id.try(:id) || id } }

    it 'returns the next upcoming open milestone ID for each project' do
      expect(milestone_ids).to contain_exactly(current_milestone_project_1.id, current_milestone_project_2.id)
    end

    context 'when the projects have no open upcoming milestones' do
      let(:projects) { [project_3] }

      it 'returns no results' do
        expect(milestone_ids).to be_empty
      end
    end
  end
end
