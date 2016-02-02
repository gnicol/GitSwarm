module SharedMirroring
  include Spinach::DSL

  def configify(config_hash)
    PerforceSwarm::GitFusion::Config.new(config_hash)
  end

  def default_config
    entry = default_entry
    entry['id'] = nil
    configify('enabled' => true, 'local' => entry)
  end

  def default_entry
    { id:  'local',
      url: 'http://user@foo',
      password: 'bar',
      git_config_params: 'http.sslVerify=false'
    }.stringify_keys
  end

  step 'Git Fusion support is disabled' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => false))
  end

  step 'The Git Fusion config block is missing' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify(nil))
  end

  step 'Git Fusion is enabled but is otherwise not configured' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => true, 'local' => {}))
  end

  step 'Git Fusion returns an empty list of managed repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return([])
  end

  step 'Git Fusion support is enabled with no auto-create enabled servers' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
  end

  step 'Git Fusion support is enabled with auto-create enabled servers' do
    config = default_config.dup
    config['global'] = { 'auto_create' => { 'path_template' => '//gitswarm/{namespace}/{project-path}',
                                            'repo_name_template' => '{namespace}-{project-path}'
                                        }
    }
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
  end

  step 'Git Fusion support is enabled with one auto-create enabled server, but with multiple servers' do
    config = default_config.dup
    config['no_auto_create2'] = { id:  'no_auto_create2',
                                  url: 'http://user@whatever2',
                                  password: 'foo2'
                               }.stringify_keys
    config['local']['auto_create'] = { 'path_template' => '//gitswarm/{namespace}/{project-path}',
                                       'repo_name_template' => '{namespace}-{project-path}'
                                     }
    config['no_auto_create'] = { id:  'no_auto_create',
                                 url: 'http://user@whatever',
                                 password: 'foo'
                              }.stringify_keys
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
  end

  step 'Git Fusion returns a list containing repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
  end
end
