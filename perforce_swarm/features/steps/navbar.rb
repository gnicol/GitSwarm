class Spinach::Features::Navbar < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedProject

  step 'I own a bare project' do
    @project = create(:empty_project, namespace: @user.namespace)
    @project.team << [@user, :master]
  end

  step 'I open the recent projects dropdown' do
    find(:css, '.navbar-gitlab .dropdown-toggle.title').click
  end

  step 'I should see "Shop" in the recent projects dropdown' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Shop')
    end
  end

  step 'I should not see "Shop" in the recent projects dropdown' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should_not have_content('Shop')
    end
  end

  step 'I should see "Forum" in the recent projects dropdown' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Forum')
    end
  end

  step 'I should see "Empty Project" in the recent projects dropdown' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Empty Project')
    end
  end
end
