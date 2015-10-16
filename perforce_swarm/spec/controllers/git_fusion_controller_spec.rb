require_relative '../spec_helper'

describe PerforceSwarm::GitFusionController, type: :controller do
  render_views
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  # ensure we can even run the tests by looking for p4d executable
  before(:all) do
    @p4d = `PATH=$PATH:/opt/perforce/sbin which p4d`.strip
  end

  # setup and teardown of temporary p4root directory
  before(:each) do
    @p4root = Dir.mktmpdir
    @p4port = "rsh:#{@p4d} -r #{@p4root} -i -q"
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return([])
  end

  after(:each) do
    FileUtils.remove_entry_secure @p4root
  end

  def configify(config_hash)
    PerforceSwarm::GitFusion::Config.new(config_hash)
  end

  def default_config
    entry = default_entry
    configify('enabled' => true, 'default' => entry)
  end

  def default_entry
    { id:       'default',
      url:      'http://user@foo',
      password: 'bar',
      git_config_params: 'http.sslVerify=false',
      perforce: { 'port' => @p4port }
    }.stringify_keys
  end

  before do
    sign_in(user)
    project.team << [user, :master]
  end

  describe 'GET existing_project' do
    it 'gives an appropriate error when Git Fusion config is missing' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify({}))
      get(:existing_project, project_id: project.id)
      expect(response).to be_success
      expect(response.body).to include('No Git Fusion configuration found.')
    end

    it 'gives an appropriate error when Git Fusion has no servers' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => true))
      get(:existing_project, project_id: project.id)
      expect(response).to be_success
      expect(response.body).to include('No Git Fusion configuration found.')
    end

    it 'gives an appropriate error when Git Fusion is not configured for auto-create' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
      get(:existing_project, project_id: project.id)
      expect(response).to be_success
      expect(response.body).to include('Auto create is not configured properly.')
    end

    it 'gives an appropriate error when Git Fusion auto-create is mis-configured' do
      config = default_config.clone
      config['default']['auto_create'] = { 'path_template' => 'yoda' }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      get(:existing_project, project_id: project.id)
      expect(response).to be_success
      expect(response.body).to include('Auto create is not configured properly.')
    end

    it 'gives an appropriate error when the requested project does not exist' do
      config = default_config.clone
      config['default']['auto_create'] = { 'path_template' => 'yoda' }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      get(:existing_project, project_id: 1000)
      expect(response).to be_success
      expect(response.body).to include("Couldn't find Project with 'id'=1000")
    end

    it 'gives the correct depot path when Git Fusion is configured properly and the requested project exists' do
      config = default_config.clone
      config['default']['auto_create'] = {
        'path_template' => '//depots/projects/{namespace}/{project-path}',
        'repo_name_template' => '{namespace}-{project-path}'
      }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      get(:existing_project, project_id: project.id)
      expect(response).to be_success
      expect(response.body).to include("//depots/projects/#{project.namespace.name}/#{project.path}/...")
    end
  end
end
