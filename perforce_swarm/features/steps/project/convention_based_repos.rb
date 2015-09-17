class Spinach::Features::ConventionBasedRepos < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication

  def configify(config_hash)
    PerforceSwarm::GitFusion::Config.new(config_hash)
  end

  def default_config
    entry = default_entry
    entry['id'] = nil
    configify('enabled' => true, 'default' => entry)
  end

  def default_entry
    { id:      'default',
      url: 'http://user@foo',
      password: 'bar',
      git_config_params: 'http.sslVerify=false'
    }.stringify_keys
  end

  step 'I select the default Git Fusion server' do
    default_server = find_by_id('git_fusion_entry').find('option[value="default"]').text
    select default_server, :from => 'git_fusion_entry'
  end

  step 'Git Fusion returns a list containing repos without convention-based mirroring' do
    pending 'step not implemented'
  end

  step 'Git Fusion returns a list containing repos with an invalid path_template' do
    pending 'step not implemented'
  end

  step 'Git Fusion returns a list containing repos with a path_template referencing a non-existent Perforce depot' do
    pending 'step not implemented'
  end

  step 'Git Fusion returns a list containing repos that have incorrect Perforce credentials' do
    allow(PerforceSwarm::P4::Connection).to receive(:login).
                                                and_raise(PerforceSwarm::P4::CredentialInvalid, 'Login failed. ')
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
  end

  step 'I should not see a convention-based mirroring radio button' do
    page.should_not have_selector('#git_fusion_auto_create_true')
  end

  step 'I should see a convention-based mirroring radio button' do
    page.should have_selector('#git_fusion_auto_create_true')
  end

  step 'I should see a disabled convention-based mirroring radio button' do
    page.should have_selector('#git_fusion_auto_create_true[disabled="disabled"]')
  end

  step 'I should see an invalid password message from Perforce' do
    pending 'not implemented'
  end

  step 'I should see a link to the convention-based mirroring help section ' do
    page.should have_content 'Auto create is not configured properly. Please see this document for help.'
    page.should have_link('help/workflow/importing/import_from_gitfusion#convention-based-repository-configuration')
  end

  step 'The Git Fusion config block is missing' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify(nil))
  end

  step 'The Git Fusion config block has a malformed URL' do
    PerforceSwarm::GitlabConfig.any_instance.stub(
        git_fusion: configify('enabled' => true, 'default' => { 'url' => 'invalid' })
    )
  end

  step 'Git Fusion support is disabled' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => false))
  end

  step 'Git Fusion returns an empty list of managed repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return([])
  end

  step 'Git Fusion is enabled but is otherwise not configured' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => true, 'default' => {}))
  end

  step 'Git Fusion returns a list containing repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
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
    page.find('#git_fusion_auto_create_false').click
  end

  step 'I should see a populated Git Fusion repo dropdown' do
    page.should have_select('git_fusion_repo_name', with_options: %w(RepoA RepoB))
  end

  step 'I should not see a Git Fusion repo dropdown' do
    page.should_not have_selector 'select#git_fusion_repo_name'
  end

end
