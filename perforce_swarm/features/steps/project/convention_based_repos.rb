require_relative '../shared/mirroring'

class Spinach::Features::ConventionBasedRepos < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include SharedProject
  include SharedMirroring

  step 'I select the default Git Fusion server' do
    default_server = find_by_id('git_fusion_entry').find('option[value="local"]').text
    select(default_server, from: 'git_fusion_entry')
  end

  step 'Git Fusion returns a list containing repos without convention-based mirroring' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
    allow(PerforceSwarm::P4::Connection).to receive(:login).and_return(true)
  end

  step 'Git Fusion returns a list containing repos with an invalid path_template' do
    config = default_config.dup
    config['global'] = { 'auto_create' => { 'path_template' => '', 'repo_name_template' => '' } }
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
    allow(PerforceSwarm::P4::Connection).to receive(:login).and_return(true)
  end

  step 'Git Fusion returns a list containing repos with a path_template referencing a non-existent Perforce depot' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::P4::Spec::Depot).to receive(:exists?).and_return(false)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
  end

  step 'Git Fusion returns a list containing repos that have incorrect Perforce credentials' do
    user          = default_config.entry.perforce_user
    error_message = 'Login failed. [P4#run] Errors during command execution( "p4 login -p" ) ' \
                    "[Error]: User #{user} doesn't exist."
    config = default_config.dup
    config['global'] = {
      'auto_create' => {
        'path_template' => '//depot/gitswarm/{namespace}/{project-path}',
        'repo_name_template' => 'gitswarm-{namespace}-{project-path}'
      }
    }
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: default_config)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('RepoA' => '', 'RepoB' => '')
    allow(PerforceSwarm::P4::Connection).to receive(:login)
      .and_raise(PerforceSwarm::P4::IdentityNotFound, error_message)
  end

  step 'I should not see a convention-based mirroring radio button' do
    page.should_not have_selector('#git_fusion_auto_create_true')
  end

  step 'I should see a clickable convention-based mirroring radio button' do
    page.should have_selector('#git_fusion_auto_create_true')
  end

  step 'I should see a disabled convention-based mirroring radio button' do
    page.should have_selector('#git_fusion_auto_create_true[disabled="disabled"]')
  end

  step 'I should see a link to the convention-based mirroring help section' do
    page.should have_content 'Auto create is not configured properly. Please see this document for help.'
    page.should have_link(
                    'this document',
                    href: '/help/workflow/importing/import_from_gitfusion#convention-based-repository-configuration'
                )
  end

  step 'The Git Fusion config block is missing' do
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify(nil))
  end

  step 'The Git Fusion config block has a malformed URL' do
    PerforceSwarm::GitlabConfig.any_instance.stub(
        git_fusion: configify('enabled' => true, 'local' => { 'url' => 'invalid' })
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
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: configify('enabled' => true, 'local' => {}))
  end

  step 'Git Fusion returns a list containing repos' do
    config = default_config.dup
    config['no_auto_create2']      = { id:  'no_auto_create2',
                                       url: 'http://user@whatever2',
                                       password: 'foo2'
                                     }.stringify_keys
    config['local']['auto_create'] = { 'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
                                       'repo_name_template' => '{namespace}-{project-path}'
                                     }
    config['local']['perforce']    = { 'port' => 'ssl:whatever:1666' }
    config['no_auto_create']       = { id:  'no_auto_create',
                                       url: 'http://user@whatever',
                                       password: 'foo'
                                     }.stringify_keys
    PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
    PerforceSwarm::P4::Connection.any_instance.stub(login: true)
    allow(PerforceSwarm::P4::Spec::Depot).to receive(:exists?).and_return(true)
    allow(PerforceSwarm::GitFusionRepo).to receive(:list).and_return('local' => '')
  end

  step 'I should see a Git Fusion is disabled message' do
    expect(page).to(
        have_content('This Helix GitSwarm instance is not pointing to any Helix Git Fusion servers.')
    )
  end

  step 'I should see a Git Fusion Configuration Error' do
    expect(page).to(
        have_content('Configuration Error:')
    )
  end

  step 'I should see a Git Fusion Communication Error' do
    expect(page).to(
        have_content('There was an error communicating with Helix Git Fusion:')
    )
  end

  step 'I should see a message saying Git Fusion has no repos available for import' do
    expect(page).to(
        have_content('Although Helix Git Fusion is configured, there are no repositories available for import.')
    )
  end

  step 'I should see a populated Git Fusion server dropdown' do
    expect(page).to(
        have_select('git_fusion_entry', with_options: [default_entry['url']])
    )
  end

  step 'I choose to import an existing repo' do
    page.find('#git_fusion_auto_create_false').click
  end

  step 'I should see a populated Git Fusion repo dropdown' do
    expect(page).to(
        have_select('git_fusion_repo_name', with_options: %w(RepoA RepoB))
    )
  end

  step 'I should not see a Git Fusion repo dropdown' do
    expect(page).to(
        have_no_selector('select#git_fusion_repo_name')
    )
  end

  step 'I should see the correct P4D depot path for convention-based mirroring' do
    expect(page).to(have_selector('code.auto-create-path'))
    expect(page.find(:code, '.auto-create-path')).to(
        have_content('//gitswarm/projects/{namespace}/{project-path}/...')
    )
  end
end
