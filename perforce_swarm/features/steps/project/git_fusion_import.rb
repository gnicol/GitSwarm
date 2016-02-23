class Spinach::Features::GitFusionImport < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication

  def configify(config_hash)
    PerforceSwarm::GitFusion::Config.new(config_hash)
  end

  def default_config
    entry = default_entry
    entry['id'] = nil
    configify('enabled' => true, 'local' => entry)
  end

  def default_entry
    { id:      'local',
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

  step 'The Git Fusion config block has a malformed URL' do
    PerforceSwarm::GitlabConfig.any_instance.stub(
      git_fusion: configify('enabled' => true, 'local' => { 'url' => 'invalid' })
    )
  end

  step 'Git Fusion is enabled but is otherwise not configured' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => true, 'local' => {}))
  end

  step 'Git Fusion returns an empty list of managed repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return([])
  end

  step 'Git Fusion returns a list containing repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
  end

  step 'Git Fusion list raises an exception' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list) { fail 'Some error.' }
  end

  step 'I should see a Git Fusion is disabled message' do
    page.should have_content 'This Helix GitSwarm instance is not pointing to any Helix Git Fusion servers.'
  end

  step 'I should see a Git Fusion Configuration Error' do
    page.should have_content 'Configuration Error:'
  end

  step 'I should see a Git Fusion Communication Error' do
    page.should have_content 'There was an error communicating with Helix Git Fusion:'
  end

  step 'I should see a message saying Git Fusion has no repos available for import' do
    page.should have_content 'Although Helix Git Fusion is configured, there are no repositories available for import.'
  end

  step 'I should see a populated Git Fusion server dropdown' do
    page.should have_select('git_fusion_entry', with_options: [default_entry['url']])
  end

  step 'I choose to import an existing repo' do
    page.find('#git_fusion_repo_create_type_import-repo').click
  end

  step 'I should see a populated Git Fusion repo dropdown' do
    page.should have_select('git_fusion_repo_name', with_options: %w(RepoA RepoB))
  end

  step 'I should not see a Git Fusion repo dropdown' do
    page.should_not have_selector 'select#git_fusion_repo_name'
  end
end
