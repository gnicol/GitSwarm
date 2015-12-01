require('spec_helper')

describe ProjectsController, type: :controller do
  render_views
  let(:project) { create(:project) }
  let(:mirrored_project) do
    create(:empty_project,
           path: 'somewhere',
           git_fusion_repo: 'mirror://foo/bar',
           git_fusion_mirrored: true)
  end
  let(:user) { create(:user) }

  # ensure we can even run the tests by looking for p4d executable
  before(:all) do
    @p4d = `PATH=$PATH:/opt/perforce/sbin which p4d`.strip
  end

  # setup and teardown of temporary p4root directory
  before(:each) do
    @p4root               = Dir.mktmpdir
    @p4port               = "rsh:#{@p4d} -r #{@p4root} -i -q"
    config_entry          = default_config.entry('default')
    @connection           = PerforceSwarm::P4::Connection.new(config_entry, @p4root)
    user_spec             = @connection.run('user', '-o', config_entry.perforce_user).last
    user_spec['Password'] = config_entry.perforce_password
    @connection.input     = user_spec
    @connection.run('user', '-i')
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return([])
  end

  after(:each) do
    FileUtils.remove_entry_secure(@p4root)
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
      perforce: { 'port' => @p4port, 'user' => 'p4test', 'password' => 'yoda' }
    }.stringify_keys
  end

  before do
    sign_in(user)
    project.team << [user, :master]
  end

  describe 'POST disable_git_fusion_mirroring' do
    it 'does nothing to the mirroring status if the project is not mirrored' do
      expect(project.git_fusion_mirrored?).to be false
      post(:disable_git_fusion_mirroring,
           namespace_id: project.namespace.to_param,
           id: project.to_param)
      expect(project.git_fusion_mirrored?).to be false
    end

    it 'disables mirroring on an already-mirrored project' do
      expect(mirrored_project.git_fusion_mirrored?).to be true
      post(:disable_git_fusion_mirroring,
           namespace_id: mirrored_project.namespace.to_param,
           id: mirrored_project.to_param)
      puts response.body.inspect
      expect(mirrored_project.git_fusion_mirrored?).to be false
    end
  end
end
