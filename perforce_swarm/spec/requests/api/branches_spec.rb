require 'spec_helper'

describe API::API, api: true do
  include ApiHelpers

  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:project) { create(:project, creator_id: user.id) }
  let!(:master) { create(:project_member, user: user, project: project, access_level: ProjectMember::MASTER) }
  let!(:guest) { create(:project_member, user: user2, project: project, access_level: ProjectMember::GUEST) }
  let!(:branch_name) { 'feature' }
  let!(:branch_sha) { '0b4bc9a49b562e85de7cc9e834518ea6828729b9' }

  describe 'DELETE /projects/:id/repository/branches/:branch' do
    before do
      require File.join(Rails.root, 'perforce_swarm', 'app', 'models', 'repository')
      module PerforceSwarm::RepositoryExtension
        alias_method :orig_rm_branch, :rm_branch
        def rm_branch(_user, _branch_name)
          true
        end
      end
    end

    after do
      PerforceSwarm::RepositoryExtension.send(:alias_method, :rm_branch, :orig_rm_branch)
    end

    it 'should remove branch', override: true do
      delete api("/projects/#{project.id}/repository/branches/#{branch_name}", user)
      expect(response.status).to eq(200)
      expect(json_response['branch_name']).to eq(branch_name)
    end

    it 'should return 404 if branch not exists', override: true do
      delete api("/projects/#{project.id}/repository/branches/foobar", user)
      expect(response.status).to eq(404)
    end

    it 'should remove protected branch', override: true do
      project.protected_branches.create(name: branch_name)
      delete api("/projects/#{project.id}/repository/branches/#{branch_name}", user)
      expect(response.status).to eq(405)
      expect(json_response['message']).to eq('Protected branch cant be removed')
    end

    it 'should not remove HEAD branch', override: true do
      delete api("/projects/#{project.id}/repository/branches/master", user)
      expect(response.status).to eq(405)
      expect(json_response['message']).to eq('Cannot remove HEAD branch')
    end
  end
end
