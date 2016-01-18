require('spec_helper')

describe ProjectsController, type: :controller do
  render_views
  let(:project) { create(:project) }
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
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return({})
    PerforceSwarm::Repo.any_instance.stub('mirror_url=' => nil)
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
    controller.instance_variable_set(:@project, project)
  end

  describe 'POST disable_helix_mirroring' do
    it 'does nothing to the mirroring status if the project is not mirrored' do
      expected_redirect = '/' + [project.namespace.to_param,
                                 project.to_param].join('/')
      expect(project.git_fusion_mirrored?).to be false
      post(:disable_helix_mirroring,
           namespace_id: project.namespace.name,
           id: project)
      expect(response).to redirect_to(expected_redirect)
      expect(project.git_fusion_mirrored?).to be false
    end

    it 'disables mirroring on an already-mirrored project' do
      expected_redirect = '/' + [project.namespace.to_param,
                                 project.to_param].join('/')
      project.git_fusion_repo     = 'mirror://default/bar'
      project.git_fusion_mirrored =  true
      expect(project.git_fusion_mirrored?).to be true

      # disable mirroring through our controller
      post(:disable_helix_mirroring,
           namespace_id: project.namespace.name,
           id: project)
      expect(response).to redirect_to(expected_redirect)
      expect(project.git_fusion_mirrored?).to be false
    end
  end

  describe 'POST reenable_helix_mirroring' do
    it 'gives error message with no mirroring status change if the project is already mirrored' do
      expected_redirect = '/' + [project.namespace.to_param,
                                 project.to_param].join('/')
      project.git_fusion_repo     = 'mirror://default/bar'
      project.git_fusion_mirrored =  true
      expect(project.git_fusion_mirrored?).to be true
      post(:reenable_helix_mirroring,
           namespace_id: project.namespace.name,
           id: project)
      expect(response).to redirect_to(expected_redirect)
      expect(project.git_fusion_mirrored?).to be true
      expect(controller).to set_flash[:alert].to('Project is already mirrored in Helix.').now
    end

    it 'gives error message with no mirroring status change if the project has no repo' do
      expected_redirect = '/' + [project.namespace.to_param,
                                 project.to_param].join('/')
      project.git_fusion_repo     = ''
      project.git_fusion_mirrored =  false
      expect(project.git_fusion_mirrored?).to be false
      post(:reenable_helix_mirroring,
           namespace_id: project.namespace.name,
           id: project)
      expect(response).to redirect_to(expected_redirect)
      expect(project.git_fusion_mirrored?).to be false
      expect(controller).to set_flash[:alert].to('Project is not associated with a Helix Git Fusion Repository.').now
    end

    it 'displays an error and leaves mirroring disabled when the Git Fusion server cannot be reached' do
      fetch_error = <<-EOM
        ssh: connect to host foo port 22: Operation timed out
        fatal: Could not read from remote repository.

        Please make sure you have the correct access rights
        and the repository exists.
      EOM

      allow(PerforceSwarm::Mirror).to receive(:fetch!).and_raise(fetch_error)
      expected_redirect = '/' + [project.namespace.to_param,
                                 project.to_param].join('/')
      project.git_fusion_repo     = 'mirror://default/bar'
      project.git_fusion_mirrored =  false
      expect(project.git_fusion_mirrored?).to be false
      post(:reenable_helix_mirroring,
           namespace_id: project.namespace.name,
           id: project)
      expect(response).to redirect_to(expected_redirect)
      expect(project.git_fusion_mirrored?).to be false
      expect(controller).to set_flash[:alert].to(fetch_error).now
    end

    it 're-enables mirroring on a project where no updates were made to Helix or GitSwarm while it was disabled' do
      expected_redirect = '/' + [project.namespace.to_param,
                                 project.to_param].join('/')
      project.git_fusion_repo     = 'mirror://default/bar'
      project.git_fusion_mirrored =  false
      expect(project.git_fusion_mirrored?).to be false
      post(:reenable_helix_mirroring,
           namespace_id: project.namespace.name,
           id: project)
      expect(response).to redirect_to(expected_redirect)
      expect(controller).to set_flash[:notice].to('Helix mirroring successfully re-enabled!').now
      expect(project.git_fusion_mirrored?).to be true
    end
  end
end
