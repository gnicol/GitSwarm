require 'spec_helper'

describe Grack::Auth, lib: true do
  let(:user)    { create(:user) }
  let(:project) { create(:project) }

  let(:app)   { ->(_env) { [200, {}, 'Success!'] } }
  let!(:auth) { Grack::Auth.new(app) }
  let(:env) do
    {
      'rack.input'     => '',
      'REQUEST_METHOD' => 'GET',
      'QUERY_STRING'   => 'service=git-upload-pack'
    }
  end
  let(:status) { auth.call(env).first }

  describe '#call' do
    context 'when the project exists' do
      before do
        env['PATH_INFO'] = project.path_with_namespace + '.git'
        class ::PerforceSwarm::Repo
          alias_method :orig_initialize, :initialize
          def initialize(path)
          end
        end
        allow_any_instance_of(PerforceSwarm::Repo).to receive(:mirrored?).and_return(false)
        # Dir.mkdir(File.join(Gitlab.config.gitlab_shell.repos_path, "#{project.path_with_namespace}.git"))
      end

      after do
        PerforceSwarm::Repo.send(:alias_method, :initialize, :orig_initialize)
      end

      context 'when the project is private' do
        before do
          project.update_attribute(:visibility_level, Project::PRIVATE)
        end

        context 'when a gitlab ci token is provided' do
          let(:token) { '123' }
          let(:project) do
            FactoryGirl.create :empty_project
          end

          before do
            project.update_attributes(runners_token: token, builds_enabled: true)

            env['HTTP_AUTHORIZATION'] =
              ActionController::HttpAuthentication::Basic.encode_credentials('gitlab-ci-token', token)
          end

          it 'responds with status 200', override: true do
            expect(status).to eq(200)
          end
        end
      end
    end
  end
end
