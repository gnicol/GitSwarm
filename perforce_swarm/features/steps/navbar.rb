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

  step 'I click on the Swarm icon' do
    find(:css, '.navbar-gitlab .app_logo').click
  end

  step 'I should see the Dashboard page' do
    find('title').should have_content('Dashboard')
  end

  step 'the title of the dropdown should be \'Dashboard\'' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').text.should eq('Dashboard')
    end
  end

  step 'I click on project "Forum"' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'Forum').click
    end
  end

  step 'the title of the dropdown should be "Forum"' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content('Forum')
    end
  end

  step 'I should see the "Forum" page' do
    find('title').should have_content('Forum')
  end

  step 'I click the Dashboard dropdown' do
    find(:css, '.navbar-gitlab .dropdown-toggle.title').click
  end

  step 'I click on \'View My Projects\' item' do
    find(:link, 'View My Projects').click
  end

  step 'I should see \'My Projects\' page' do
    find(:css, '.page-title').should have_content('My Projects')
  end

  step 'I click on \'View All Public Projects\' item' do
    find(:link, 'View All Public Projects').click
  end

  step 'I should see \'Explore GitLab\' page' do
    find('title').should have_content('Explore | GitLab')
  end

  step 'the title of the dropdown should be \'Explore\'' do
    within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').text.should eq('Explore')
    end
  end
end
