class Spinach::Features::Navbar < Spinach::FeatureSteps
  include SharedAdmin
  include SharedAuthentication
  include SharedGroups
  include SharedIssues
  include SharedMergeRequests
  include SharedPaths
  include SharedProfile
  include SharedProject
  include SharedSearch

  #########################
  # Data
  #########################

  step 'I own a bare project' do
    @project = create(:empty_project, namespace: @user.namespace)
    @project.team << [@user, :master]
  end

  step 'I visit empty project page' do
    project = Project.find_by(name: 'Empty Project')
    visit namespace_project_path(project.namespace, project)
  end

  step 'I visit project "Forum" page' do
    project = Project.find_by(name: 'Forum')
    visit namespace_project_path(project.namespace, project)
  end

  step 'I visit project "Shop" page' do
    project = Project.find_by(name: 'Shop')
    visit namespace_project_path(project.namespace, project)
  end

  #########################
  # Dropdown - Dropdown Menu
  #########################

  step 'I should see "Empty Project" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Empty Project')
    end
  end

  step 'I should see "Forum" at the top of the list in the recent projects dropdown' do
    page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content('Forum')
  end

  step 'I should see "Forum" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Forum')
    end
  end

  step 'I should no longer see the project "PerforceProject" in the dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should_not have_content('PerforceProject')
    end
  end

  step 'I should see "PerforceProject" with "NewUserQA" user name in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('NewUserQA')
    end
  end

  step 'I should see "PerforceProject" with "QA" group name in the recent projects dropdown' do
    page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content('QA')
    page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content('PerforceProject')
  end

  step 'I should see "Recent Projects" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Recent Projects')
    end
  end

  step 'I should not see "Recent Projects" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should_not have_content('Recent Projects')
    end
  end

  step 'I should see "Shop" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should have_content('Shop')
    end
  end

  step 'I should not see "Shop" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-menu').should_not have_content('Shop')
    end
  end

  step 'I should see "Shop" then "Forum" then "Empty Project" in the recent projects dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      menuitems = page.all(:css, '.dropdown-menu li')
      menuitems[1].should have_content('Shop')
      menuitems[2].should have_content('Forum')
      menuitems[3].should have_content('Empty Project')
    end
  end

  step 'I should not see any projects in the recent projects dropdown' do
    page.all('.dashboard-menu .dropdown-menu li').count.should eq(3)
    page.all('.dashboard-menu .dropdown-menu li')[0].text.should have_content('Dashboard')
  end

  #########################
  # Dropdown - Dropdown Menu - Top of the List
  #########################

  step 'I should not see "Shop" as the latest project in the dropdown' do
    page.within '.navbar-gitlab .dashboard-menu' do
      page.all(:css, '.dropdown-menu li')[1].should_not have_content('Shop')
    end
  end

  step 'I should see "New Project" at the top of the list in the recent projects dropdown' do
    page.within '.navbar-gitlab' do
      page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content('new-project')
      page.all('.dashboard-menu ul.dropdown-menu li')[2].text.should_not have_content('new-project')
    end
  end

  step 'I should see "PerforceProject" at the top of the list in the recent projects dropdown' do
    page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content('PerforceProject')
  end

  step 'I should see "QAProject" at the top of the list in the recent projects dropdown' do
    page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content('QAProject')
  end

  step 'I should see the project with the project name over 100 characters at the top of the list' do
    page.all('.dashboard-menu ul.dropdown-menu li')[1].text.should have_content(long_project_name + long_project_name)
  end

  step 'I should not see "PerforceProject" second on the list in the recent projects dropdown' do
    page.all('.dashboard-menu ul.dropdown-menu li')[2].text.should_not have_content('PerforceProject')
  end

  #########################
  # Dropdown - Dropdown Click Actions
  #########################

  step 'I open the recent projects dropdown' do
    find(:css, '.navbar-gitlab .dropdown-toggle.title').trigger('click')
  end

  step 'I click on the Recent Projects dropdown' do
    find(:css, '.navbar-gitlab .dropdown-toggle.title').trigger('click')
  end

  step 'I click on project "Forum"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'Forum').trigger('click')
    end
  end

  step 'I click on project "PerforceProject"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'PerforceProject').trigger('click')
    end
  end

  step 'I click on project "QAProject"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'QAProject').trigger('click')
    end
  end

  step 'I click on "View My Starred Projects" link' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'View My Starred Projects').trigger('click')
    end
  end

  step 'I click on "View All Projects" link' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'View All Projects').trigger('click')
    end
  end

  step 'I click on "Dashboard" link' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'Dashboard').trigger('click')
    end
  end

  step 'I click on the most recent project under "Recent Projects"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      first('.dashboard-menu ul.dropdown-menu li a').trigger('click')
    end
  end

  step 'I click on the older project "Shop" in "Recent Projects"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:link, 'Shop').trigger('click')
    end
  end

  #########################
  # Dropdown - Dropdown Title
  #########################

  step 'the title of the dropdown should be "Admin"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content('Admin')
    end
  end

  step 'the title of the dropdown should be "Forum"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content('Forum')
    end
  end

  step 'the title of the dropdown should be "QAGroup"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content('QAGroup')
    end
  end

  step 'the title of the dropdown should be "QAProject"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content('QAProject')
    end
  end

  step 'the title of the dropdown should be "Search"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content('Search')
    end
  end

  step 'the title of the dropdown should the project name over 100 characters' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').should have_content(long_project_name)
    end
  end

  #########################
  # Navigation
  #########################

  step 'I click on the Swarm icon' do
    find(:css, '.header-logo').click
  end

  step 'I click on the back button' do
    page.evaluate_script('window.history.back()')
  end

  #########################
  # Pages
  #########################

  step 'I should see the login page' do
    find(:css, '.login-page').should have_button('Sign in')
  end

  step 'I should see the Dashboard page' do
    expect(page).to have_field('filter_projects', type: 'search')
  end

  step 'I should see the Dashboard page with no projects' do
    find('a[href="/projects/new"]').should have_content('New Project')
  end

  step 'I should see the "All Projects" page' do
    expect(find('title')).to have_content('Explore')
    page.assert_selector('.public-projects')
  end

  step 'I should see the "Forum" page' do
    find('title').should have_content('Forum')
  end

  step 'I should see an empty "My Starred Projects" page' do
    expect(page).to have_content('You don\'t have starred projects yet')
  end

  step 'I should see the "QAProject" page' do
    project = Project.find_by(name: 'QAProject')
    expect(page).to have_field('project_clone', with: project.url_to_repo)
  end

  step 'I should see the "PerforceProject" page' do
    project = Project.find_by(name: 'PerforceProject')
    expect(page).to have_field('project_clone', with: project.url_to_repo)
  end

  step 'I should see a project page' do
    page.within '.sidebar-wrapper' do
      find(:css, '.shortcuts-project').should have_content('Project')
    end
  end

  step 'I should see the user page' do
    page.should have_content('User Activity')
  end

  step 'I should see the user settings page' do
    find(:css, '.page-title').should have_content('Profile')
  end

  step 'I should see the new project page' do
    find('title').should have_content('New Project')
    page.assert_selector('form.new_project')
  end

  #########################
  # Top Nav
  #########################

  step 'the title of the dropdown should be "Dashboard"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').text.should eq('Dashboard')
    end
  end

  step 'the title of the dropdown should be "Explore"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').text.should eq('Explore')
    end
  end

  step 'the title of the dropdown should be "New Project"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').text.should have_content('new-project')
    end
  end

  step 'the title of the dropdown should be "PerforceProject"' do
    page.within '.navbar-gitlab .dashboard-menu' do
      find(:css, '.dropdown-toggle').text.should have_content('PerforceProject')
    end
  end

  #########################
  # User Menu
  #########################

  step 'I click on the User Menu icon' do
    find(:css, '.profile-pic').click
  end

  step 'I click on "Logout" link' do
    find(:css, '.logout').click
  end

  step 'I click on "Profile" link' do
    find(:css, '.profile-link').click
  end

  step 'I click on "My Settings" link' do
    find(:xpath, "//a[@href='/profile']").click
  end
end
