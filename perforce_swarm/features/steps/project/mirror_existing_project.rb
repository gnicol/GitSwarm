require_relative '../shared/mirroring'

class Spinach::Features::MirrorExistingProject < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include SharedProject
  include SharedMirroring

  step 'I should see a disabled Helix Mirroring button' do
    page.should have_selector('a.btn.disabled', text: 'Helix Mirroring')
  end

  step 'I should see a Helix Mirroring button' do
    page.should have_text('Helix Mirroring')
    page.should_not have_selector('a.btn.disabled', text: 'Helix Mirroring')
  end

  step 'I should not see a Helix Mirroring button' do
    page.should_not have_content('Helix Mirroring')
  end

  step 'I should see the Disable Helix Mirroring button' do
    page.should have_selector('a.btn', text: 'Disable Helix Mirroring')
    page.should_not have_selector('a.btn.disabled', text: 'Disable Helix Mirroring')
  end

  step 'I should see the Re-enable Helix Mirroring button' do
    page.should have_selector('a.btn', text: 'Re-enable Helix Mirroring')
    page.should_not have_selector('a.btn.disabled', text: 'Re-enable Helix Mirroring')
  end

  step 'I should see a no Git Fusion instances configured tooltip' do
    page.should have_selector('li[data-title*="no Git Fusion instances have been configured."]')
  end

  step 'I should see a no Git Fusion instances configured for auto-create tooltip' do
    page.should have_selector('li[data-title*="None of the Helix Git Fusion instances GitSwarm knows about ' \
                              'are configured for \'auto create\'."]'
                             )
  end

  step 'I should see an inadequate permissions tooltip' do
    page.should have_selector('li[data-title*="but you lack permissions to enable it for this project."]')
  end

  step 'I should see a disabled or mis-configured tooltip' do
    page.should have_selector('li[data-title*="Helix Git Fusion integration is disabled."]')
  end

  step 'Helix mirroring is enabled for project "Shop"' do
    project = create(:project, name: 'Shop', git_fusion_repo: 'mirror://local/foo', git_fusion_mirrored: true)
    project.team << [@user, :master]
  end

  step 'Helix mirroring is not enabled for project "Shop"' do
    project = create(:project, name: 'Shop')
    project.team << [@user, :master]
  end

  step 'Helix mirroring is disabled, but was once enabled for project "Shop"' do
    project = create(:project, name: 'Shop', git_fusion_repo: 'mirror://local/foo', git_fusion_mirrored: false)
    project.team << [@user, :master]
  end

  step 'I am an admin of project "Shop"' do
    project   = Project.find_by(name: 'Shop')
    project ||= create(:project, name: 'Shop')
    project.team << [@user, :master]
  end

  step 'I am a member of project "Shop"' do
    project   = Project.find_by(name: 'Shop')
    project ||= create(:project, name: 'Shop')
    project.team << [@user, :reporter]
  end

  step 'I am not a member of project "Shop"' do
    project   = Project.find_by(name: 'Shop')
    project ||= create(:project, name: 'Shop')
    project.team << [@user, :guest]
  end

  step 'I should see "Not Mirrored in Helix" under the clone URL field' do
    page.within('.project-stats > ul.nav > li.mirrored-status') do
      page.should have_link('Not Mirrored in Helix')
    end
  end

  step 'I should see "Mirrored in Helix" under the clone URL field' do
    page.within('.project-stats > ul.nav > li.mirrored-status') do
      page.should have_link('Mirrored in Helix')
      page.should_not have_link('Not Mirrored in Helix')
    end
  end

  step 'I click the Helix Mirroring button' do
    page.click_link('Helix Mirroring')
  end

  step 'I should be on the Helix Mirroring page for the "Shop" project' do
    project = Project.find_by(name: 'Shop')
    expect(page.current_path).to eq(configure_helix_mirroring_namespace_project_path(project.namespace, project))
  end

  step 'The Git Fusion repo selected by default is the first one that has auto_create enabled' do
    first_auto_create = nil
    PerforceSwarm::GitlabConfig.new.git_fusion.entries.each do |id, entry|
      next unless entry.auto_create_configured?
      first_auto_create = id
      break
    end
    expect(first_auto_create).to_not be_nil
    expect(page.find('#git_fusion_entry').find('option[selected]').value).to eq(first_auto_create)
  end

  step 'I select a Git Fusion repo that does not support auto-create' do
    allow(PerforceSwarm::GitFusion).to receive(:run).and_return('')
    page.within('.mirroring-server-select') do
      select('no_auto_create2', from: 'git_fusion_entry')
    end
  end

  step 'I select a Git Fusion repo with an resolvable hostname' do
    # note that by NOT stubbing PerforceSwarm::GitFusion.run, the error comes
    # from the code that checks our Perforce connection
    page.within('.mirroring-server-select') do
      select('no_auto_create2', from: 'git_fusion_entry')
    end
  end

  step 'The Git Fusion depot path info is done loading' do
    expect(page.find(:div, '.git-fusion-mirroring-data')).to_not have_selector('.fa-spinner.fa-spin')
  end

  step 'I should see an error message that says auto-create is not configured properly' do
    expect(page.find(:div, '.mirroring-errors')).to have_content('Auto create is not configured properly.')
  end

  step 'I should see an error message that says there was an error communicating with Helix Git Fusion' do
    expect(page.find(:div, '.mirroring-errors')).to(
      have_content('There was an error communicating with Helix Git Fusion: ')
    )
  end
end
