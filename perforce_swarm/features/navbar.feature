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
  Scenario: I should see my 5 most recent projects in my recent project dropdown
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

  #########################
  # Dashboard Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on the Swarm icon from the 'Public Projects' page and verify that user is taken to the Dashboard page
    Given I visit the public projects area
    When I click on the Swarm icon
    Then I should see the Dashboard page
    And the title of the dropdown should be 'Dashboard'

  @javascript @automated @PGL-123
  Scenario: Click on a project on the Dashboard dropdown and verify that user is taken to the project page
    Given I own project "Forum"
    And I visit dashboard page
    When I click on the Recent Projects dropdown
    And I click on project "Forum"
    Then I should see the "Forum" page
    And the title of the dropdown should be "Forum"

  @automated @PGL-123
  Scenario: Click on 'View My Projects' on Dashboard dropdown and verify that user is taken to 'My Projects' page
    Given I click on the Recent Projects dropdown
    And I click on 'View My Projects' link
    Then I should see 'My Projects' page

  @automated @PGL-123
  Scenario: Click on 'View All Public Projects' on Dashboard dropdown and verify that user is taken to 'Public Projects' page
    Given I click on the Recent Projects dropdown
    And I click on 'View All Public Projects' link
    Then I should see the 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

  #########################
  # Project Dropdown
  #########################

  @automated @PGL-123
  Scenario: Click on 'Dashboard' on the Project dropdown and verify that user is taken to the Dashboard page
    Given I own project "PerforceProject"
    When I visit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    And I click on 'Dashboard' link
    Then I should see the Dashboard page

  @automated @PGL-123
  Scenario: Click on 'View My Projects' on Project dropdown and verify that user is taken to 'My Projects' page
    Given I own project "PerforceProject"
    When I visit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    And I click on 'View My Projects' link
    Then I should see 'My Projects' page

  @automated @PGL-123
  Scenario: Click on 'View All Public Projects' on Project dropdown and verify that user is taken to 'Public Projects' page
    Given I own project "PerforceProject"
    When I visit project "PerforceProject" page
    And I click on the Recent Projects dropdown
    And I click on 'View All Public Projects' link
    Then I should see the 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

  @javascript @automated @PGL-123
  Scenario: Create a new project and verify that the project appears on the Project dropdown
    When I visit new project page
    And create a project named "New Project"
    Then I should see the "New Project" project page
    And the title of the dropdown should be "New Project"
    When I click on the Recent Projects dropdown
    Then I should see "New Project" at the top of the list in the recent projects dropdown

  @javascript @PGL-123 @automated
  Scenario: Rename a project and verify that project name appears correctly on the Dashboard and Project dropdowns
    Given I own project "PerforceProject"
    And I visit project "PerforceProject" settings page
    When I rename the project "PerforceProject" to "QAProject"
    And I click on the Recent Projects dropdown
    Then I should see "QAProject" at the top of the list in the recent projects dropdown
    And the title of the dropdown should be 'QAProject'
    When I click on project "QAProject"
    Then I should see the "QAProject" page

  @PGL-123
  Scenario: Rename project with a long name and verify that the project name appears correctly on the Dashboard and Project dropdowns
    When I visit project "PerforceProject" settings page
    And I rename the project with a very long name
    When I click on the Recent Projects dropdown
    Then I should see the renamed project link
    And the title of the dropdown should be the renamed project name

  @PGL-123
  Scenario: Transfer project to a different user and verify that project name appears correctly on the Dashboard and Project dropdowns
    When I visit project "PerforceProject" settings page
    And I transfer the project to a different user
    When I click on the Recent Projects dropdown
    Then I should see the transferred project link
    And the title of the dropdown should be the transferred project name
    When I click on the transferred project link
    Then I should see the transferred project dashboard

  @PGL-123
  Scenario: Transfer project to a different group and verify that project name appears correctly on the Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I transfer the project to a different group
    When I click on the Recent Projects dropdown
    Then I should see the transferred project link
    And the title of the dropdown should be the transferred project name

  @PGL-123
  Scenario: Remove project and verify that the project no longer appears on the Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I remove the project
    When I click on the Recent Projects dropdown
    Then I should no longer see the project

  @PGL-123
  Scenario: Archive project and verify that the project no longer appears on Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I archive the project
    When I click on the Recent Projects dropdown
    Then I should no longer see the project

  #########################
  # Search Dropdown
  #########################

  @javascript @automated @PGL-123
  Scenario: Go to the Search page by searching for a project, click on a project on the Search dropdown and verify that user is taken to the project page
    Given I own project "PerforceProject"
    When I visit dashboard search page
    And I search for "Perforce"
    Then the title of the dropdown should be 'Search'
    When I click on the Recent Projects dropdown
    And I click on the most recent project under "Recent Projects"
    Then I should see a project page

  @automated @PGL-123
  Scenario: Click on 'View My Projects' on Search dropdown and verify that user is taken to 'My Projects' page
    Given I visit dashboard search page
    And I click on the Recent Projects dropdown
    When I click on 'View My Projects' link
    Then I should see 'My Projects' page

  @automated @PGL-123
  Scenario: Click on 'View All Public Projects' on Search dropdown and verify that user is taken to 'Public Projects' page
    Given I visit dashboard search page
    And I click on the Recent Projects dropdown
    When I click on 'View All Public Projects' link
    Then I should see the 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'
    And the title of the dropdown should be 'Explore'

  #########################
  # Snippet Dropdown
  #########################

  @automated @PGL-123
  Scenario: Click on 'View My Projects' on Snippet dropdown and verify that user is taken to 'My Projects' page
    Given I own project "Shop"
    And I visit project "Shop" snippets page
    When I click on the Recent Projects dropdown
    And I click on 'View My Projects' link
    Then I should see 'My Projects' page

  @PGL-123
  Scenario: Click on a project on the Snippet dropdown and verify that user is taken to the project page
    When I click on the Snippet icon
    Then the title of the dropdown should be 'Snippets'
    When I click on a project link
    Then I should see the project dashboard

  @PGL-123
  Scenario: Click on 'View All Public Projects' on Snippet dropdown and verify that user is taken to 'Public Projects' page
    When I click on the Snippet icon
    And I click on 'View All Public Projects' link
    Then I should see 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

  #########################
  # Admin Dropdown
  #########################

  @automated @PGL-123
  Scenario: Click on 'View All Public Projects' on Admin dropdown and verify that admin is taken to 'Public Projects' page
    Given I logout
    And I sign in as an admin
    And I visit admin page
    When I click on the Recent Projects dropdown
    And I click on 'View All Public Projects' link
    Then I should see the 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

  @PGL-123
  Scenario: Click on a project on the Admin dropdown and verify that admin is taken to the project page
    Given I sign in as an admin
    And I click on the admin area icon
    Then the title of the dropdown should be 'Admin area'
    When I click on a project link
    Then I should see the project dashboard
    And the title of the dropdown should be the project name

  @PGL-123
  Scenario: Click on 'View My Projects' on Admin dropdown and verify that admin is taken to 'My Projects' page
    Given I sign in as an admin
    And I click on the admin area icon
    And I click on 'View My Projects' link
    Then I should see 'My Projects' page

  #########################
  # User Menu Dropdown
  #########################

  @automated @PGL-123
  Scenario: Click on the 'Profile' link of User Menu dropdown and verify that user is taken to the user page
    When I click on the User Menu icon
    And I click on 'Profile' link
    Then I should see the user page

  @automated @PGL-123
  Scenario: Click on the 'My Settings' link of User Menu dropdown and verify that user is taken to the user settings page
    When I click on the User Menu icon
    And I click on 'My Settings' link
    Then I should see the user settings page

  @PGL-123
  Scenario: Click on the 'Logout' link of User Menu dropdown and verify that user is logged out
    When I click on the User Menu icon
    And I logout
    Then I should see the GitLab home page

  #########################
  # 'Recent Projects' of Dashboard, Project, and User Menu dropdowns
  #########################

  @javascript @automated @PGL-123
  Scenario: Create an issue in an older project and verify that project appears first under 'Recent Projects' of Project dropdown
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit dashboard page
    And I click on the Recent Projects dropdown
    Then I should see "Forum" at the top of the list in the recent projects dropdown
    When I visit project "PerforceProject" issues page
    And I click link "New Issue"
    And I submit new issue "New Issue"
    When I visit dashboard page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @javascript @PGL-123 @automated
  Scenario: Create a merge request in an older project and verify that project appears first under 'Recent Projects' of User Menu dropdown
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" merge requests page
    And I click link "New Merge Request"
    When I submit new merge request "PerforceProject Merge Request"
    Then I should see merge request "PerforceProject Merge Request"
    When I visit dashboard page
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" at the top of the list in the recent projects dropdown

  @PGL-123
  Scenario: Push a commit in an older project and verify that project appears first under 'Recent Projects' of Dashboard dropdown
    Given I own project "PerforceProject"
    And I own project "Forum"
    When I visit project "PerforceProject" commits page
    And I push a commit to the project
    And I click on the Recent Projects dropdown
    Then the project should appear on the top of the list in 'Recent Projects'

  #########################
  # Back Button Behavior
  #########################

  @javascript @automated @PGL-123
  Scenario: Click on the back button after navigating to a project and verify that user is taken to the Dashboard page
    Given I own project "PerforceProject"
    And I visit dashboard page
    And I click on the Recent Projects dropdown
    And I click on project "PerforceProject"
    When I click on the back button
    Then I should see the Dashboard page

  @javascript @automated @PGL-123
  Scenario: Click on the back button after creating a project and verify that project still appears in the Dashboard dropdown
    When I visit new project page
    And create a project named "New Project"
    Then I should see the "New Project" project page
    And the title of the dropdown should be "New Project"
    When I click on the back button
    And I click on the Swarm icon
    And I click on the Recent Projects dropdown
    Then I should see "New Project" at the top of the list in the recent projects dropdown

  @PGL-123
  Scenario: Click on the back button after navigating to the 'Public Projects' page from a project page and verify that user is taken to the project page
    Given I am on the project page
    And I click on 'View All Public Projects' link
    When I click on the back button
    Then I should see the project page

  @PGL-123
  Scenario: Click on the back button after renaming a project and verify that project is still renamed in the Project dropdown
    When I visit project "PerforceProject" settings page
    And I rename the project
    When I click on the back button
    When I click on the Recent Projects dropdown
    Then I should see the renamed project link
    And the title of the dropdown should be the renamed project name
    When I click on the renamed project link
    Then I should see the renamed project dashboard

  @PGL-123
  Scenario: Click on the back button after transferring a project and verify that project is still renamed in the Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I transfer the project
    When I click on the back button
    When I click on the Recent Projects dropdown
    Then I should see the renamed project link
    And the title of the dropdown should be the transferred project name

  @PGL-123
  Scenario: Click on the back button after navigating to a project from the Admin page and verify that admin is taken to the Admin page
    Given I sign in as an admin
    And I click on the admin area icon
    When I click on a project link
    And I click on the back button
    Then I should see the admin area
    And the title of the dropdown should be 'Admin area'

  @PGL-123
  Scenario: Click on the back button after navigating to a project from the Search page and verify that user is taken to the Search page
    Given I search for "Perforce"
    When I click on a project link
    And I click on the back button
    Then I should see the Search page
    And the title of the dropdown should be 'Search'

  @PGL-123
  Scenario: Click on the back button after navigating to a project from the Snippet page and verify that user is taken to the Snippet page
    When I click on the Snippet icon
    And I click on a project link
    And I click on the back button
    Then I should see the Snippet page
    And the title of the dropdown should be 'Snippets'

  #########################
  # Admin - Related
  #########################

  @javascript @automated @PGL-123
  Scenario: As an admin, transfer a project in the admin area to a different group, verify that the project name should be renamed in the Dashboard dropdown
    And I logout
    When I sign in as an admin
    And I own project "PerforceProject"
    When I visit admin "PerforceProject" project page
    And group 'QA' exists
    And I transfer project "PerforceProject" to "QA"
    Then I should see project transferred to group "QA"
    And I click on the Recent Projects dropdown
    Then I should see "PerforceProject" with "QA" group name

  @automated @PGL-123
  Scenario: As an admin, remove a project in the admin area, verify that the project is removed from the Dashboard dropdown
    And I logout
    When I sign in as an admin
    And I own project "PerforceProject"
    When I visit admin projects page
    And I destroy "PerforceProject"
    When I click on the Recent Projects dropdown
    Then I should not see any projects in the recent projects dropdown

  @PGL-123
  Scenario: As an admin, rename a project in the admin area, verify that the project name should be renamed in the Project dropdown.
    Given I sign in as an admin
    And I visit project "PerforceProject" settings page
    And I rename the project
    When I click on the Recent Projects dropdown
    Then I should see the renamed project link
    And the title of the dropdown should be the renamed project name
    When I click on the renamed project link
    Then I should see the renamed project dashboard

  @PGL-123
  Scenario: As an admin, remove a project in the admin area, verify that the project is removed from the Dashboard dropdown
    Given I sign in as an admin
    And I visit project "PerforceProject" settings page
    When I visit project "PerforceProject" settings page
    And I remove the project
    When I click on the Recent Projects dropdown
    Then I should no longer see the project

  @PGL-123
  Scenario: As an admin, click on the 'Profile' link of the User Menu dropdown and verify that admin is taken to the admin user page
    Given I sign in as an admin
    When I click on the User Menu icon
    And I click on 'Profile' link
    Then I should see the user page

  @PGL-123
  Scenario: As an admin, click on the 'My Settings' link of the User Menu dropdown and verify that admin is taken to the admin settings page
    Given I sign in as an admin
    When I click on the User Menu icon
    And I click on 'My Settings' link
    Then I should see the user settings page

  @PGL-123
  Scenario: As an admin, click on the 'Logout' link of the User Menu dropdown and verify that admin is logged out
    Given I sign in as an admin
    When I click on the User Menu icon
    And I logout
    Then I should see the GitLab home page

  #########################
  # User and Group - Related
  #########################

  @javascript @automated @PGL-123
  Scenario: Create a new user and verify that the Dashboard dropdown does not have 'Recent Projects'
    When I click on the Recent Projects dropdown
    Then I should not see any projects in the recent projects dropdown

  @javascript @PGL-123 @automated
  Scenario: Rename user and verify that projects in Profile dropdown are renamed
    Given I own project "PerforceProject"
    And I visit profile page
    When I change the username to "NewUserQA" in 'Profile settings'
    And the profile settings should be updated
    When I click on the Recent Projects dropdown
    Then I should see "PerforceProject" with "NewUserQA" user name

  @PGL-123
  Scenario: Create a new user and a new project and verify that the project appears on the Project dropdown
    Given I sign in as a new user
    And I create a new project
    When I click on the Recent Projects dropdown
    Then I should see only that project under 'Recent Projects'

  @PGL-123
  Scenario: Rename user and verify projects in Dashboard dropdown are renamed
    When I change my username in the user settings page
    And I click on the Swarm icon
    And I click on the Recent Projects dropdown
    Then my projects names should be changed to new name

  @PGL-123
  Scenario: Rename group and verify projects in Dashboard dropdown are renamed
    When I change a group name in the group settings page
    And I click on the Swarm icon
    And I click on the Recent Projects dropdown
    Then the projects names should be changed to new group name

  @PGL-123
  Scenario: Rename group and verify projects in Project dropdown are renamed
    When I change a group name in the group settings page
    And I click on the Swarm icon
    And I click on a project
    Then the title of the dropdown should have renamed group name

  #########################
  # Appearance Themes - Manual testing
  #########################

  @manual @PGL-123
  Scenario: Change the Appearance Theme and verify the dropdowns and hover responses appear and function as expected
    When I click on the User Menu icon
    And I click on 'My Settings' dropdown
    And I click on the 'Design' page
    When I click on another Application theme
    Then the background color of the top nav should match the theme
    And the Dashboard dropdown, Project dropdown, and User Menu dropdown should have expected project lists and hover responses
    And the Search dropdown, Snippets dropdown, and Explore dropdown should have expected project lists and hover responses

  #########################
  # Browser Window Resizing - Manual testing
  #########################

  @manual @PGL-123
  Scenario: Resize the browser window on Dashboard page and verify that Dashdboard dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the Swarm icon
    And I click on the Recent Projects dropdown
    Then I should see 'Recent Projects', 'Dashboard', 'View My Projects' and 'View All Projects'

  @manual @PGL-123
  Scenario: Resize browser window on Project page and verify that Project dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the Recent Projects dropdown
    And I click on a project link
    Then I should see the project dashboard
    And I click on the dropdown of the project dashboard
    Then I should see 'Recent Projects', 'Dashboard', 'View My Projects' and 'View All Projects'

  @manual @PGL-123
  Scenario: Resize browser window on User settings page and verify that User Menu dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the User Menu icon
    Then I should see 'Profile', 'My Settings', and 'Logout'

  #########################
  # Mobile Testing - Manual testing
  # Perform some manual tests on mobile devices/emulators and verify that navbar appears and functions as expected
  #########################
