class Spinach::Features::MirrorExistingProject < Spinach::FeatureSteps
  include SharedPaths
  include SharedAuthentication
  include SharedProject
  include SharedMirroring

  step 'I should see a disabled Mirror in Helix button' do
    page.should have_selector('a.btn.disabled', :text => 'Mirror in Helix')
  end

  step 'I should see a Mirror in Helix button' do
    page.should have_link('Mirror in Helix')
    page.should_not have_selector('a.btn.disabled', :text => 'Mirror in Helix')
  end

  step 'I should not see a Mirror in Helix button' do
    page.should_not have_link('Mirror in Helix')
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
    page.should have_selector('li[data-title*="you do not have adequate permissions to enable it for this project."]')
  end

  step 'I should see a disabled or mis-configured tooltip' do
    page.should have_selector('li[data-title*="Helix Git Fusion integration is disabled or mis-configured."]')
  end

  step 'Helix mirroring is enabled for project "Foo"' do
    ProjectsHelper.stub(:mirrored?, true)
  end

  step 'I visit project "Foo" page' do
    project = Project.find_by(name: 'Foo')
    visit namespace_project_path(project.namespace, project)
  end

  step 'I am a member of project "Shop"' do
    project = create(:project, name: "Shop")
    project.team << [@user, :reporter]
  end

  step 'I am a member of project "Foo"' do
    project = create(:project, name: "Foo")
    project.team << [@user, :reporter]
  end

  step 'I am an admin of project "Foo"' do
    project = create(:project, name: "Foo")
    project.team << [@user, :admin]
  end
end
