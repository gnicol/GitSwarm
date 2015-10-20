require_relative '../shared/mirroring'

class Spinach::Features::MirrorExistingProject < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include SharedProject
  include SharedMirroring

  step 'I should see a disabled Mirror in Helix button' do
    page.should have_selector('a.btn.disabled', text: 'Mirror in Helix')
  end

  step 'I should see a Mirror in Helix button' do
    page.should have_text('Mirror in Helix')
    page.should_not have_selector('a.btn.disabled', text: 'Mirror in Helix')
  end

  step 'I should not see a Mirror in Helix button' do
    page.should_not have_content('Mirror in Helix')
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
    allow(ProjectsHelper).to receive(:mirrored?).and_return(true)
    project = create(:project, name: 'Shop', git_fusion_repo: 'mirror://default/foo')
    project.team << [@user, :master]
  end

  step 'Helix mirroring is not enabled for project "Shop"' do
    allow(ProjectsHelper).to receive(:mirrored?).and_return(false)
    project = create(:project, name: 'Shop')
    project.team << [@user, :master]
  end

  step 'I am an admin of project "Shop"' do
    project = create(:project, name: 'Shop')
    project.team << [@user, :master]
  end

  step 'I am a member of project "Shop"' do
    project = create(:project, name: 'Shop')
    project.team << [@user, :reporter]
  end

  step 'I am not a member of project "Shop"' do
    project = create(:project, name: 'Shop')
    project.team << [@user, :guest]
  end

  step 'I should see "not mirrored in helix" under the clone URL field' do
    page.should have_link('not mirrored in helix')
  end

  step 'I should see "mirrored in helix" under the clone URL field' do
    page.should have_link('mirrored in helix')
  end
end
