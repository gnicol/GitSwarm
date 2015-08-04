class Spinach::Features::GitFusionImport < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication

  def default_config
    entry = default_entry
    entry['id'] = nil
    { 'enabled' => true, 'default' => entry }
  end

  def default_entry
    { id:      'default',
      url: 'http://user@foo',
      password: 'bar',
      git_config_params: 'http.sslVerify=false'
    }.stringify_keys
  end

  step 'Git Fusion support is disabled' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: { 'enabled' => false })
  end

  step 'The Git Fusion config block is missing' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: nil)
  end

  step 'The Git Fusion config block has a malformed URL' do
    PerforceSwarm::GitlabConfig.any_instance.stub(
        git_fusion: { 'enabled' => true, 'default' => { 'url' => 'invalid' } }
      )
  end

  step 'Git Fusion is enabled but is otherwise not configured' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: { 'enabled' => true, 'default' => {} })
  end

  step 'Git Fusion returns an empty list of managed repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion_entry: default_entry)
    PerforceSwarm::GitFusionRepo.stub(list: [])
  end

  step 'Git Fusion returns a list containing repos' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion_entry: default_entry)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
  end

  step 'I should see a Git Fusion is disabled message' do
    page.should have_content 'This GitSwarm instance is not pointing to any Git Fusion servers.'
  end

  step 'I should see a message saying Git Fusion has no repos available for import' do
    page.should have_content 'Although Git Fusion is configured, there are no repos available for import.'
  end

  step 'I should see a populated Git Fusion repo dropdown' do
    page.should have_select('git_fusion_repo_name', with_options: %w(RepoA RepoB))
  end

  step 'I should not see a Git Fusion repo dropdown' do
    page.should_not have_selector 'select#git_fusion_repo_name'
  end
end
