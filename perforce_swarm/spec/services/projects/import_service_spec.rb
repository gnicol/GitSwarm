require 'spec_helper'

describe Projects::ImportService, services: true do
  let!(:project) { create(:empty_project) }
  let(:user) { project.creator }

  subject { described_class.new(project, user) }

  describe '#execute' do
    context 'with valid importer', override: true do
      before do
        stub_github_omniauth_provider

        project.import_url = 'https://github.com/vim/vim.git'
        project.import_type = 'github'

        allow(project).to receive(:import_data).and_return(double.as_null_object)
        puts 'Providers: ' + Gitlab.config.omniauth.providers.inspect
      end

      it 'succeeds if importer succeeds' do
        expect_any_instance_of(Gitlab::Shell).to receive(:import_repository)
          .with(project.path_with_namespace, project.import_url).and_return(true)
        expect_any_instance_of(Gitlab::GithubImport::Importer).to receive(:execute).and_return(true)

        result = subject.execute

        expect(result[:status]).to eq :success
      end

      it 'flushes various caches', override: true do
        expect_any_instance_of(Gitlab::Shell).to receive(:import_repository)
          .with(project.path_with_namespace, project.import_url)
          .and_return(true)

        expect_any_instance_of(Gitlab::GithubImport::Importer).to receive(:execute)
          .and_return(true)

        expect_any_instance_of(Repository).to receive(:expire_emptiness_caches)
          .and_call_original

        expect_any_instance_of(Repository).to receive(:expire_exists_cache)
          .and_call_original

        subject.execute
      end

      it 'fails if importer fails', override: true do
        expect_any_instance_of(Gitlab::Shell).to receive(:import_repository)
          .with(project.path_with_namespace, project.import_url).and_return(true)
        expect_any_instance_of(Gitlab::GithubImport::Importer).to receive(:execute).and_return(false)

        result = subject.execute

        expect(result[:status]).to eq :error
        expect(result[:message]).to eq 'The remote data could not be imported.'
      end

      it 'fails if importer raise an error', override: true do
        expect_any_instance_of(Gitlab::Shell).to receive(:import_repository)
          .with(project.path_with_namespace, project.import_url).and_return(true)
        expect_any_instance_of(Gitlab::GithubImport::Importer).to receive(:execute)
          .and_raise(Projects::ImportService::Error.new('Github: failed to connect API'))

        result = subject.execute

        expect(result[:status]).to eq :error
        expect(result[:message]).to eq 'Github: failed to connect API'
      end
    end

    def stub_github_omniauth_provider
      # remove any existing providers
      # Gitlab.config.omniauth.providers.replace([])

      provider = OpenStruct.new(
        'name' => 'github',
        'app_id' => 'asd123',
        'app_secret' => 'asd123',
        'args' => {
          'client_options' => {
            'site' => 'https://github.com/api/v3',
            'authorize_url' => 'https://github.com/login/oauth/authorize',
            'token_url' => 'https://github.com/login/oauth/access_token'
          }
        }
      )

      Gitlab.config.omniauth.providers << provider
    end
  end
end
