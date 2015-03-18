@navbar
Feature: NavBar
  Background:
    Given I sign in as a user

  @javascript @automated @PGL-123
  Scenario: I should see project "Shop" in my recent project dropdown
    Given I own project "Shop"
    And I visit dashboard page
    When I open the recent projects dropdown
    Then I should see "Shop" in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: I should see my 5 most recently updated projects in my recent project dropdown
    Given I own project "Shop"
    And I own project "Forum"
    And I own an empty project
    And I own a bare project
    And I own a bare project
    And I own a bare project
    And I visit dashboard page
    When I open the recent projects dropdown
    Then I should not see "Shop" in the recent projects dropdown
    And I should see "Forum" in the recent projects dropdown
    And I should see "Empty Project" in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: I should see recent projects if I am a member of at least one project
    Given I own project "Shop"
    And I visit dashboard page
    And I open the recent projects dropdown
    Then I should see "Recent Projects" in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: I should not see any recent projects when no projects have been created yet
    Given I visit dashboard page
    And I open the recent projects dropdown
    Then I should not see "Recent Projects" in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: I should see the recent projects update as I view projects
    Given I own project "Forum"
    And I own project "Shop"
    And I own an empty project
    Then I should not see "Shop" as the latest project in the dropdown
    When I visit empty project page
    And I visit project "Forum" page
    And I visit project "Shop" page
    Then I should see "Shop" then "Forum" then "Empty Project" in the recent projects dropdown

  #########################
  # Dashboard Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on the Swarm icon from the "Public Projects" page and verify that user is taken to the Dashboard page
    Given I visit the public projects area
    When I click on the Swarm icon
    Then I should see the Dashboard page with no projects
    And the title of the dropdown should be "Dashboard"

  @javascript @automated @PGL-123
  Scenario: Click on a project on the Dashboard dropdown and verify that user is taken to the project page
    Given I own project "Forum"
    And I visit dashboard page
    When I click on the Recent Projects dropdown
    And I click on project "Forum"
    Then I should see the "Forum" page
    And the title of the dropdown should be "Forum"

  @javascript @automated @PGL-123
  Scenario: Click on "View My Starred Projects" on Dashboard dropdown and verify that user is taken to "My Starred Projects" page
    Given I click on the Recent Projects dropdown
    And I click on "View My Starred Projects" link
    Then I should see an empty "My Starred Projects" page

  @javascript @automated @PGL-123
  Scenario: Click on "View All Projects" on Dashboard dropdown and verify that user is taken to "Public Projects" page
    Given I click on the Recent Projects dropdown
    And I click on "View All Projects" link
    Then I should see the "Explore" page
    And the title of the dropdown should be "Explore"

  #########################
  # Project Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on "Dashboard" on the Project dropdown and verify that user is taken to the Dashboard page
    Given I own project "PerforceProject"
    When I visit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    And I click on "Dashboard" link
    Then I should see the Dashboard page

  @javascript @automated @PGL-123
  Scenario: Click on "View My Starred Projects" on Project dropdown and verify that user is taken to "My Starred Projects" page
    Given I own project "PerforceProject"
    When I visit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    And I click on "View My Starred Projects" link
    Then I should see an empty "My Starred Projects" page

  @javascript @automated @PGL-123
  Scenario: Click on "View All Projects" on Project dropdown and verify that user is taken to "Public Projects" page
    Given I own project "PerforceProject"
    When I visit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    And I click on "View All Projects" link
    Then I should see the "Explore" page
    And the title of the dropdown should be "Explore"

  @javascript @automated @PGL-123
  Scenario: Create a new project and verify that the project appears on the Project dropdown
    When I visit new project page
    And create a project named "New Project"
    Then I should see the "New Project" project page
    And the title of the dropdown should be "New Project"
    When I click on the Recent Projects dropdown
    Then I should see "New Project" at the top of the list in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: Rename a project and verify that project name appears correctly on the Dashboard and Project dropdowns
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I rename the project "PerforceProject" to "QAProject"
    Then the title of the dropdown should be "QAProject"
    When I click on the Recent Projects dropdown
    Then I should see "QAProject" at the top of the list in the recent projects dropdown
    When I click on project "QAProject"
    Then I should see the "QAProject" page

  @javascript @automated @PGL-123
  Scenario: Rename project with a long name and verify that the project name appears correctly on the Dashboard and Project dropdowns
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I rename the project "PerforceProject" to a project with a name over 100 characters
    Then the title of the dropdown should the project name over 100 characters
    When I click on the Recent Projects dropdown
    Then I should see the project with the project name over 100 characters at the top of the list

  @javascript @PGL-123 @PGL-504
  Scenario: Rename the path of a project and verify that the project name appears correctly on the Dashboard and Project dropdowns
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I rename the path of project "PerforceProject" to "PerforceProjectRenamed"
    Then the title of the dropdown should be "PerforceProject"
    When I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown
    And I should not see "PerforceProject" second on the list in the recent projects dropdown
    When I click on project "PerforceProject"
    Then the path of the page should include "PerforceProjectRenamed"

  @javascript @PGL-123 # TODO:  Need to figure out dropdown select issues of transferring user in project.
  Scenario: Transfer project to a different user and verify that project name appears correctly on the Dashboard and Project dropdowns
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I transfer the project "PerforceProject" to another user

  @javascript @PGL-123 # TODO:  Need to figure out dropdown select issues of changing group to project.
  Scenario: Transfer project to a different group and verify that project name appears correctly on the Dashboard dropdown
    Given I own project "PerforceProject"
    And I visit dashboard page
    And I click new group link
    And submit form with new group "QAGroup" info
    Then I should be redirected to group "QAGroup" page
    And I should see newly created group "QAGroup"
    When I visit project "PerforceProject" settings page
    And I transfer the project to "QAGroup" group
    And I transfer the project
    Then the title of the dropdown should be "QAGroup"

  @javascript @PGL-123 @PGL-504 # Currently blocked by PGL-504
  Scenario: Remove project and verify that the project no longer appears on the Dashboard dropdown
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I remove the project
    When I click on the Recent Projects dropdown
    Then I should no longer see the project "PerforceProject" in the dropdown

  @javascript @PGL-123 @PGL-504 # Currently blocked by PGL-504
  Scenario: Archive project and verify that the project no longer appears on Dashboard dropdown
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I archive the project
    When I click on the Recent Projects dropdown
    Then I should no longer see the project "PerforceProject" in the dropdown

  #########################
  # Search Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Go to the Search page by searching for a project, click on a project on the Search dropdown and verify that user is taken to the project page
    Given I own project "PerforceProject"
    When I search for "Perforce"
    Then the title of the dropdown should be "Search"
    When I click on the Recent Projects dropdown
    And I click on the most recent project under "Recent Projects"
    Then I should see a project page

  @javascript @automated @PGL-123
  Scenario: Click on "View All Projects" on Search dropdown and verify that user is taken to "Public Projects" page
    Given I visit dashboard search page
    And I click on the Recent Projects dropdown
    When I click on "View All Projects" link
    Then I should see the "Explore" page
    And the title of the dropdown should be "Explore"

  #########################
  # Snippet Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on "View My Starred Projects" on Snippet dropdown and verify that user is taken to "My Starred Projects" page
    Given I own project "Shop"
    And I visit project "Shop" snippets page
    When I click on the Recent Projects dropdown
    And I click on "View My Starred Projects" link
    Then I should see an empty "My Starred Projects" page

  @javascript @automated @PGL-123
  Scenario: Click on a project on the Snippet dropdown and verify that user is taken to the project page
    Given I own project "Shop"
    And I own project "Forum"
    And I visit project "Shop" snippets page
    When I click on the Recent Projects dropdown
    And I click on project "Forum"
    Then I should see the "Forum" page
    And the title of the dropdown should be "Forum"

  #########################
  # Admin Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on "View All Projects" on Admin dropdown and verify that admin is taken to "Public Projects" page
    Given I logout
    Then I should see the login page
    When I sign in as an admin
    And I visit admin page
    When I click on the Recent Projects dropdown
    And I click on "View All Projects" link
    Then I should see the "Explore" page
    And the title of the dropdown should be "Explore"

  @javascript @automated @PGL-123
  Scenario: Click on a project on the Admin dropdown and verify that admin is taken to the project page
    Given I logout
    Then I should see the login page
    When I sign in as an admin
    And I own project "Shop"
    And I own project "Forum"
    And I visit admin page
    Then the title of the dropdown should be "Admin"
    When I click on the Recent Projects dropdown
    And I click on project "Forum"
    Then I should see the "Forum" page
    And the title of the dropdown should be "Forum"

  #########################
  # User Menu Dropdown
  #########################

  @automated @PGL-123
  Scenario: Click on the "Profile" link of User Menu dropdown and verify that user is taken to the user page
    When I click on the User Menu icon
    And I click on "Profile" link
    Then I should see the user page

  @automated @PGL-123
  Scenario: Click on the "My Settings" link of User Menu dropdown and verify that user is taken to the user settings page
    When I click on the User Menu icon
    And I click on "My Settings" link
    Then I should see the user settings page

  @automated @PGL-123
  Scenario: Click on the "Logout" link of User Menu dropdown and verify that user is logged out
    When I click on the User Menu icon
    And I click on "Logout" link
    Then I should see the login page

  #########################
  # Back Button Behavior
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on the back button after navigating to a project and verify that user is taken to the Dashboard page
    Given I own project "PerforceProject"
    And I visit dashboard page
    And I click on the Recent Projects dropdown
    And I click on project "PerforceProject"
    Then I should see the "PerforceProject" page
    When I click on the back button
    Then I should see the Dashboard page

  @javascript @automated @PGL-123
  Scenario: Click on the back button after creating a project and verify that project still appears in the Dashboard dropdown
    When I visit new project page
    And create a project named "New Project"
    Then I should see the "New Project" project page
    And the title of the dropdown should be "New Project"
    When I click on the back button
    Then I should see the new project page
    When I click on the Swarm icon
    Then I should see the Dashboard page
    When I click on the Recent Projects dropdown
    Then I should see "New Project" at the top of the list in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: Click on the back button after renaming a project and verify that project is still renamed in the Project dropdown
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I rename the project "PerforceProject" to "QAProject"
    Then the title of the dropdown should be "QAProject"
    When I click on the back button
    Then the title of the dropdown should be "QAProject"

  @javascript @automated @PGL-123
  Scenario: Click on the back button after navigating to a project from the Admin page and verify that admin is taken to the Admin page
    And I logout
    Then I should see the login page
    When I sign in as an admin
    And I own project "PerforceProject"
    When I visit admin page
    And I click on the Recent Projects dropdown
    And I click on project "PerforceProject"
    Then I should see the "PerforceProject" page
    When I click on the back button
    Then I should see the Admin area page
    Then the title of the dropdown should be "Admin"

  @javascript @automated @PGL-123
  Scenario: Click on the back button after navigating to a project from the Search page and verify that user is taken to the Search page
    Given I own project "PerforceProject"
    When I search for "Perforce"
    Then the title of the dropdown should be "Search"
    When I click on the Recent Projects dropdown
    And I click on the most recent project under "Recent Projects"
    Then I should see the "PerforceProject" page
    When I click on the back button
    Then I should see the Search page
    Then the title of the dropdown should be "Search"

  #########################
  # Admin - Related
  #########################

  @javascript @automated @PGL-123
  Scenario: As an admin, transfer a project in the admin area to a different group, verify that the project name should be renamed in the Dashboard dropdown
    And I logout
    Then I should see the login page
    When I sign in as an admin
    And I own project "PerforceProject"
    When I visit admin "PerforceProject" project page
    And group "QA" exists
    And I transfer project "PerforceProject" to "QA"
    Then I should see project "PerforceProject" transferred to group "QA"
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" with "QA" group name in the recent projects dropdown

  @javascript @automated @PGL-123
  Scenario: As an admin, remove a project in the admin area, verify that the project is removed from the Dashboard dropdown
    And I logout
    Then I should see the login page
    When I sign in as an admin
    And I own project "PerforceProject"
    When I visit admin projects page
    And I destroy "PerforceProject"
    When I click on the Recent Projects dropdown
    Then I should not see any projects in the recent projects dropdown

  @javascript @PGL-123
  Scenario: As an admin, click on the "Profile" link of the User Menu dropdown and verify that admin is taken to the admin user page
    And I logout
    Then I should see the login page
    When I sign in as an admin
    When I click on the User Menu icon
    And I click on "Profile" link
    Then I should see the admin user page

  @javascript @automated @PGL-123
  Scenario: As an admin, click on the "My Settings" link of the User Menu dropdown and verify that admin is taken to the admin settings page
    And I logout
    Then I should see the login page
    When I sign in as an admin
    When I click on the User Menu icon
    And I click on "My Settings" link
    When I click on the User Menu icon
    Then I should see the admin user settings page

  @javascript @PGL-123
  Scenario: As an admin, click on the "Logout" link of the User Menu dropdown and verify that admin is logged out
    And I logout
    Then I should see the login page
    When I sign in as an admin
    When I click on the User Menu icon
    And I click on "Logout" link
    Then I should see the login page

  #########################
  # User and Group - Related
  #########################

  @javascript @automated @PGL-123
  Scenario: Create a new user and verify that the Dashboard dropdown does not have "Recent Projects"
    When I click on the Recent Projects dropdown
    Then I should not see any projects in the recent projects dropdown

  @javascript @PGL-123
  Scenario: Create a new user and a new project and verify that the project appears on the Project dropdown
    Given I sign in as a new user
    And I create a new project
    When I click on the Recent Projects dropdown
    Then I should see only that project under "Recent Projects"

  @javascript @automated @PGL-123
  Scenario: Rename user and verify that projects in Profile dropdown are renamed
    Given I own project "PerforceProject"
    And I visit profile page
    When I change the username to "NewUserQA" in "Profile settings"
    And the profile settings should be updated
    When I click on the Recent Projects dropdown
    Then I should see "PerforceProject" with "NewUserQA" user name in the recent projects dropdown

  @javascript @PGL-123 # TODO:  Need to figure out dropdown select issues of changing group to project.
  Scenario: Rename group and verify projects in Dashboard dropdown are renamed
    Given I own project "PerforceProject"
    And group "QA" exists
    When I transfer project "PerforceProject" to "QA"
    When I click on the Swarm icon
    And I click on the Recent Projects dropdown
    Then the projects names should be changed to new group name

  #########################
  # Tracking recently visited project pages
  #########################

  @javascript @automated @PGL-448
  Scenario:  Click on an older project in the dropdown and verify that afterwards, the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    And I visit dashboard page
    When I click on the Recent Projects dropdown
    Then I should see "Forum" at the top of the list in the recent projects dropdown
    When I visit project "PerforceProject" page
    Then I should see the "PerforceProject" page
    And the title of the dropdown should be "PerforceProject"
    When I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on a blob file link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" blob file page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated @PGL-448 @PGL-509
  Scenario:  Click on a commit link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" commit page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on a compare refs link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" compare refs page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on a deploy keys link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" deploy keys page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on edit project link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit edit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on files link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" files page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on hooks link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" hooks page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated @PGL-448
  Scenario:  Click on an issue link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" issues page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @PGL-448 @PGL-510
  Scenario:  Click on a merge request link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" merge request page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on network link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" network page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on protected branches link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" protected branches page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on a snippet link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" snippets page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on tags link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" tags page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @automated
  Scenario:  Click on a wiki link of an older project, and verify that the project appears on the top of the dropdown.
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" wiki page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  #########################
  # Appearance Themes - Manual testing
  #########################

  @PGL-123
  Scenario: Change the Appearance Theme and verify the dropdowns and hover responses appear and function as expected
    When I click on the User Menu icon
    And I click on "My Settings" dropdown
    And I click on the "Design" page
    When I click on another Application theme
    Then the background color of the top nav should match the theme
    And the Dashboard dropdown, Project dropdown, and User Menu dropdown should have expected project lists and hover responses
    And the Search dropdown, Snippets dropdown, and Explore dropdown should have expected project lists and hover responses

  #########################
  # Browser Window Resizing - Manual testing
  #########################

  @PGL-123
  Scenario: Resize the browser window on Dashboard page and verify that Dashdboard dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the Swarm icon
    And I click on the Recent Projects dropdown
    Then I should see "Recent Projects", "Dashboard", "View My Starred Projects" and "View All Projects"

  @PGL-123
  Scenario: Resize browser window on Project page and verify that Project dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the Recent Projects dropdown
    And I click on a project link
    Then I should see the project dashboard
    And I click on the dropdown of the project dashboard
    Then I should see "Recent Projects", "Dashboard", "View My Starred Projects" and "View All Projects"

  @PGL-123
  Scenario: Resize browser window on User settings page and verify that User Menu dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the User Menu icon
    Then I should see "Profile", "My Settings", and "Logout"

  #########################
  # Mobile Testing - Manual testing
  # Perform some manual tests on mobile devices/emulators and verify that navbar appears and functions as expected
  #########################
