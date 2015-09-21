# This is an override test, so use the parent spec_helper
require 'spec_helper'

describe Projects::CreateService do
  describe :create_by_user do
    before do
      @user = create :user
      @opts = {
        name: 'GitLab',
        namespace: @user.namespace
      }
    end

    context 'repository creation' do
      it 'should synchronously create the repository', override: true do
        expect_any_instance_of(PerforceSwarm::ProjectExtension).to receive(:create_repository)

        project = create_project(@user, @opts)
        expect(project).to be_valid
        expect(project.owner).to eq(@user)
        expect(project.namespace).to eq(@user.namespace)
      end
    end
  end

  def create_project(user, opts)
    Projects::CreateService.new(user, opts).execute
  end
end
