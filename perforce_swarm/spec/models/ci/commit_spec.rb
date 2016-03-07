require 'spec_helper'

describe Ci::Commit, models: true do
  let(:project) { FactoryGirl.create :empty_project }
  let(:commit) { FactoryGirl.create :ci_commit, project: project }

  describe :gitlab_ci? do
    context 'with [ci skip]' do
      before do
        allow(commit).to receive(:git_commit_message) { 'message [ci skip]' }
      end

      it 'always returns true no matter what skip_ci is set to' do
        [nil, false, true].each do |value|
          allow_any_instance_of(Repository).to receive(:skip_ci?).and_return(value)
          expect(commit.skip_ci?).to be_truthy
        end
      end
    end

    context 'without [ci skip]' do
      before do
        allow(commit).to receive(:git_commit_message) { 'message without skip' }
      end

      it 'returns true when skip_ci is set to true, false otherwise' do
        [nil, false, true].each do |value|
          allow_any_instance_of(Repository).to receive(:skip_ci?).and_return(value)
          expect(commit.skip_ci?).to value ? be_truthy : be_falsey
        end
      end
    end
  end
end
