require 'spec_helper'

describe Ci::Commit, models: true do
  let(:project) { FactoryGirl.create :empty_project }
  let(:commit) { FactoryGirl.create :ci_commit, project: project }

  describe :skip_ci? do
    context 'with [ci skip]' do
      before do
        allow(commit).to receive(:git_commit_message) { 'message [ci skip]' }
      end

      it 'always returns true no matter what skip_ci is set to' do
        allow(Gitlab.config).to receive(:skip_ci).and_return(nil)
        expect(commit.skip_ci?).to be_truthy

        allow(Gitlab.config).to receive(:skip_ci).and_return(false)
        expect(commit.skip_ci?).to be_truthy

        allow(Gitlab.config).to receive(:skip_ci).and_return(true)
        expect(commit.skip_ci?).to be_truthy
      end
    end

    context 'without [ci skip]' do
      before do
        allow(commit).to receive(:git_commit_message) { 'message without skip' }
      end

      it 'returns true when skip_ci is set to true, false otherwise' do
        allow(Gitlab.config).to receive(:skip_ci).and_return(nil)
        expect(commit.skip_ci?).to be_falsey

        allow(Gitlab.config).to receive(:skip_ci).and_return(false)
        expect(commit.skip_ci?).to be_falsey

        allow(Gitlab.config).to receive(:skip_ci).and_return(true)
        expect(commit.skip_ci?).to be_truthy
      end
    end
  end
end
