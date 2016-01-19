require 'spec_helper'

describe API::API, api: true do
  include ApiHelpers
  let(:user) { create(:user) }
  let!(:project) { create(:project, namespace: user.namespace) }
  let(:file_path) { 'files/ruby/popen.rb' }

  before do
    require 'repository'
    project.team << [user, :developer]
  end

  describe 'POST /projects/:id/repository/files' do
    let(:valid_params) do
      {
        file_path: 'newfile.rb',
        branch_name: 'master',
        content: 'puts 8',
        commit_message: 'Added newfile'
      }
    end

    it 'should return a 400 if editor fails to create file', override: true do
      module PerforceSwarm::RepositoryExtension
        alias_method :orig_commit_file, :commit_file
        def commit_file(_user, _path, _content, _message, _branch, _update)
          false
        end
      end

      post api("/projects/#{project.id}/repository/files", user), valid_params
      expect(response.status).to eq(400)
      PerforceSwarm::RepositoryExtension.send(:alias_method, :commit_file, :orig_commit_file)
    end
  end

  describe 'DELETE /projects/:id/repository/files' do
    let(:valid_params) do
      {
        file_path: file_path,
        branch_name: 'master',
        commit_message: 'Changed file'
      }
    end

    it 'should return a 400 if fails to create file', override: true do
      module PerforceSwarm::RepositoryExtension
        alias_method :orig_remove_file, :remove_file
        def remove_file(_user, _path, _message, _branch)
          false
        end
      end

      delete api("/projects/#{project.id}/repository/files", user), valid_params
      expect(response.status).to eq(400)
      PerforceSwarm::RepositoryExtension.send(:alias_method, :remove_file, :orig_remove_file)
    end
  end
end
