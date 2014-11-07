Feature: NavBar
  Background:
    Given I sign in as a user

  @automated
  Scenario: I should see project "Shop" in my recent project dropdown
    Given I own project "Shop"
      And I visit dashboard page
    When I open the recent projects dropdown
    Then I should see "Shop" in the recent projects dropdown

  @automated
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

  @automated
  Scenario: Click on the Swarm icon and verify that user is taken to the Dashboard page
    Given I click on the Swarm icon
    Then I should see the Dashboard page
      And the title of the dropdown should be 'Dashboard'

  @automated
  Scenario: Click on a project on the Dashboard dropdown and verify that user is taken to the project page
    Given I own project "Forum"
      And I visit dashboard page
    When I open the recent projects dropdown
      And I click on project "Forum"
    Then I should see the "Forum" page
      And the title of the dropdown should be "Forum"
 
  @automated
  Scenario: Click on 'View My Projects' on Dashboard dropdown and verify that user is taken to 'My Projects' page
    Given I click the Dashboard dropdown
      And I click on 'View My Projects' item
    Then I should see 'My Projects' page
      
  @automated
  Scenario: Click on 'View All Public Projects' on Dashboard dropdown and verify that user is taken to 'Public Projects' page
    Given I click the Dashboard dropdown
      And I click on 'View All Public Projects' item
    Then I should see 'Explore GitLab' page
      And the title of the dropdown should be 'Explore'

#########################
# Project Dropdown
#########################

  Scenario: Click on 'Dashboard' on the Project dropdown and verify that user is taken to the Dashboard page
    When I visit project "PerforceProject" page
    And I click on the Project dropdown
    And I click on 'Dashboard' item
    Then I should see the Dashboard page

  Scenario: Click on 'View My Projects' on Project dropdown and verify that user is taken to 'My Projects' page
    When I visit project "PerforceProject" page
    And I click on 'View My Projects' item
    Then I should see 'My Projects' page

  Scenario: Click on 'View All Public Projects' on Project dropdown and verify that user is taken to 'Public Projects' page
    When I visit project "PerforceProject" page
    And I click on 'View All Public Projects' item
    Then I should see 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

  Scenario: Create a new project and verify that the project appears on the Project dropdown
    When I visit new project page
    And fill project form with valid data
    Then the title of the dropdown should be the name of the new project
    When I click on the Project dropdown
    Then I should see the new project item on the top of the list

  Scenario: Rename a project and verify that project name appears correctly on the Dashboard and Project dropdowns
    When I visit project "PerforceProject" settings page
    And I rename the project
    When I click on the Dashboard dropdown
    Then I should see the renamed project item
    And the title of the dropdown should be the renamed project name
    When I click on the renamed project item
    Then I should see the renamed project dashboard

  Scenario: Rename project with a long name and verify that the project name appears correctly on the Dashboard and Project dropdowns
    When I visit project "PerforceProject" settings page
    And I rename the project with a very long name
    When I click on the Dashboard dropdown
    Then I should see the renamed project item
    And the title of the dropdown should be the renamed project name

  Scenario: Transfer project to a different user and verify that project name appears correctly on the Dashboard and Project dropdowns
    When I visit project "PerforceProject" settings page
    And I transfer the project to a different user
    When I click on the Dashboard dropdown
    Then I should see the transferred project item
    And the title of the dropdown should be the transferred project name
    When I click on the transferred project item
    Then I should see the transferred project dashboard

  Scenario: Transfer project to a different group and verify that project name appears correctly on the Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I transfer the project to a different group
    When I click on the Dashboard dropdown
    Then I should see the transferred project item
    And the title of the dropdown should be the transferred project name

  Scenario: Remove project and verify that the project no longer appears on the Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I remove the project
    When I click on the Dashboard dropdown
    Then I should no longer see the project

  Scenario: Archive project and verify that the project no longer appears on Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I archive the project
    When I click on the Dashboard dropdown
    Then I should no longer see the project

#########################
# Search Dropdown
#########################

  Scenario: Click on a project on the Search dropdown and verify that user is taken to the project page
    Given I search for "Perforce"
    Then the title of the dropdown should be 'Search'
    When I click on a project item
    Then I should see the project dashboard

  Scenario: Click on 'View My Projects' on Search dropdown and verify that user is taken to 'My Projects' page
    Given I search for "Perforce"
    And I click on 'View My Projects' item
    Then I should see 'My Projects' page

  Scenario: Click on 'View All Public Projects' on Search dropdown and verify that user is taken to 'Public Projects' page
    Given I search for "Perforce"
    And I click on 'View All Public Projects' item
    Then I should see 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

#########################
# Snippet Dropdown
#########################

  Scenario: Click on a project on the Snippet dropdown and verify that user is taken to the project page
    When I click on the Snippet icon
    Then the title of the dropdown should be 'Snippets'
    When I click on a project item
    Then I should see the project dashboard

  Scenario: Click on 'View My Projects' on Snippet dropdown and verify that user is taken to 'My Projects' page
    When I click on the Snippet icon
    And I click on 'View My Projects' item
    Then I should see 'My Projects' page

  Scenario: Click on 'View All Public Projects' on Snippet dropdown and verify that user is taken to 'Public Projects' page
    When I click on the Snippet icon
    And I click on 'View All Public Projects' item
    Then I should see 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

#########################
# Admin Dropdown
#########################

  Scenario: Click on a project on the Admin dropdown and verify that admin is taken to the project page
    Given I sign in as an admin
    And I click on the admin area icon
    Then the title of the dropdown should be 'Admin area'
    When I click on a project item
    Then I should see the project dashboard
    And the title of the dropdown should be the project name

  Scenario: Click on 'View My Projects' on Admin dropdown and verify that admin is taken to 'My Projects' page
    Given I sign in as an admin
    And I click on the admin area icon
    And I click on 'View My Projects' item
    Then I should see 'My Projects' page

  Scenario: Click on 'View All Public Projects' on Admin dropdown and verify that admin is taken to 'Public Projects' page
    Given I sign in as an admin
    And I click on the admin area icon
    And I click on 'View All Public Projects' item
    Then I should see 'Explore GitLab' page
    And the title of the dropdown should be 'Explore'

#########################
# User Menu Dropdown
#########################

  Scenario: Click on the 'Profile' link of User Menu dropdown and verify that user is taken to the user page
    When I click on the User Menu icon
    And I click on 'Profile' link
    Then I should see the user page

  Scenario: Click on the 'My Settings' link of User Menu dropdown and verify that user is taken to the user settings page
    When I click on the User Menu icon
    And I click on 'My Settings' link
    Then I should see the user settings page

  Scenario: Click on the 'Logout' link of User Menu dropdown and verify that user is logged out
    When I click on the User Menu icon
    And I click on 'Logout' link
    Then I should see the GitLab home page

#########################
# 'Recent Projects' of Dashboard, Project, and User Menu dropdowns
#########################

  Scenario: Push a commit in an older project and verify that project appears first under 'Recent Projects' of Dashboard dropdown
    When I click on an old project in 'Recent Projects'
    And I push a commit to the project
    And I click on the Dashboard dropdown
    Then the project should appear on the top of the list in 'Recent Projects'

  Scenario: Create an issue in an older project and verify that project appears first under 'Recent Projects' of Project dropdown
    When I click on an old project in 'Recent Projects'
    And I create an issue on the project
    And I click on the Project dropdown
    Then the project should appear on the top of the list in 'Recent Projects'

  Scenario: Create a merge request in an older project and verify that project appears first under 'Recent Projects' of User Menu dropdown
    When I click on an old project in 'Recent Projects'
    And I create a merge request on the project
    When I click on the User Menu icon
    And I click on 'Profile' link
    Then the project should appear on the top of the list in 'Recent Projects'

#########################
# Back Button Behavior
#########################

  Scenario: Click on the back button after navigating to a project and verify that user is taken to the Dashboard page
    When I click on the Dashboard dropdown
    And I click on a project item
    And I click on the back button
    Then I should see Dashboard page

  Scenario: Click on the back button after navigating to the 'Public Projects' page from a project page and verify that user is taken to the project page
    Given I am on the project page
    And I click on 'View All Public Projects' item
    When I click on the back button
    Then I should see the project page

  Scenario: Click on the back button after creating a project and verify that project still appears in the Dashboard dropdown
    When I visit new project page
    And fill project form with valid data
    When I click on the back button
    And I click on the Swarm icon
    When I click the Dashboard dropdown
    Then I should see the new project item on the top of the list

  Scenario: Click on the back button after renaming a project and verify that project is still renamed in the Project dropdown
    When I visit project "PerforceProject" settings page
    And I rename the project
    When I click on the back button
    When I click on the Dashboard dropdown
    Then I should see the renamed project item
    And the title of the dropdown should be the renamed project name
    When I click on the renamed project item
    Then I should see the renamed project dashboard

  Scenario: Click on the back button after transferring a project and verify that project is still renamed in the Dashboard dropdown
    When I visit project "PerforceProject" settings page
    And I transfer the project
    When I click on the back button
    When I click on the Dashboard dropdown
    Then I should see the renamed project item
    And the title of the dropdown should be the transferred project name

  Scenario: Click on the back button after navigating to a project from the Admin page and verify that admin is taken to the Admin page
    Given I sign in as an admin
    And I click on the admin area icon
    When I click on a project item
    And I click on the back button
    Then I should see the admin area
    And the title of the dropdown should be 'Admin area'

  Scenario: Click on the back button after navigating to a project from the Search page and verify that user is taken to the Search page
    Given I search for "Perforce"
    When I click on a project item
    And I click on the back button
    Then I should see the Search page
    And the title of the dropdown should be 'Search'

  Scenario: Click on the back button after navigating to a project from the Snippet page and verify that user is taken to the Snippet page
    When I click on the Snippet icon
    And I click on a project item
    And I click on the back button
    Then I should see the Snippet page
    And the title of the dropdown should be 'Snippets'

#########################
# Admin-Related
#########################

  Scenario: As an admin, rename a project in the admin area, verify that the project name should be renamed in the Project dropdown.
    Given I sign in as an admin
    And I visit project "PerforceProject" settings page
    And I rename the project
    When I click on the Dashboard dropdown
    Then I should see the renamed project item
    And the title of the dropdown should be the renamed project name
    When I click on the renamed project item
    Then I should see the renamed project dashboard

  Scenario: As an admin, transfer a project in the admin area, verify that the project name should be renamed in the Dashboard dropdown
    Given I sign in as an admin
    And I visit project "PerforceProject" settings page
    And I transfer the project
    When I click on the Dashboard dropdown
    Then I should see the transferred project item

  Scenario: As an admin, remove a project in the admin area, verify that the project is removed from the Dashboard dropdown
    Given I sign in as an admin
    And I visit project "PerforceProject" settings page
    When I visit project "PerforceProject" settings page
    And I remove the project
    When I click on the Dashboard dropdown
    Then I should no longer see the project

  Scenario: As an admin, click on the 'Profile' link of the User Menu dropdown and verify that admin is taken to the admin user page
    Given I sign in as an admin
    When I click on the User Menu icon
    And I click on 'Profile' link
    Then I should see the user page

  Scenario: As an admin, click on the 'My Settings' link of the User Menu dropdown and verify that admin is taken to the admin settings page
    Given I sign in as an admin
    When I click on the User Menu icon
    And I click on 'My Settings' link
    Then I should see the user settings page

  Scenario: As an admin, click on the 'Logout' link of the User Menu dropdown and verify that admin is logged out
    Given I sign in as an admin
    When I click on the User Menu icon
    And I click on 'Logout' link
    Then I should see the GitLab home page

#########################
# New User
#########################

  Scenario: Create a new user and verify that the Dashboard dropdown does not have 'Recent Projects'
    Given I sign in as a new user
    And I click on the Dashboard dropdown
    Then I should not see any projects under 'Recent Projects'

  Scenario: Create a new user and a new project and verify that the project appears on the Project dropdown
    Given I sign in as a new user
    And I create a new project
    When I click on the Dashboard dropdown
    Then I should see only that project under 'Recent Projects'

#########################
# Rename User
#########################

  Scenario: Rename user and verify projects in Dashboard dropdown are renamed
    When I change my username in the user settings page
    And I click on the Swarm icon
    And I click on the Dashboard dropdown
    Then my projects names should be changed to new name

  Scenario: Rename user and verify that projects in Profile dropdown are renamed
    When I change my username in the user settings page
    And I click on the User Menu icon
    And I click on 'Profile' link
    Then my projects names should be changed to new name

#########################
# Appearance Themes - Manual testing
#########################

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

  Scenario: Resize the browser window on Dashboard page and verify that Dashdboard dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the Swarm icon
    And I click on the Dashboard dropdown
    Then I should see 'Recent Projects', 'Dashboard', 'View My Projects' and 'View All Projects'

  Scenario: Resize browser window on Project page and verify that Project dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the Dashboard dropdown
    And I click on a project item
    Then I should see the project dashboard
    And I click on the dropdown of the project dashboard
    Then I should see 'Recent Projects', 'Dashboard', 'View My Projects' and 'View All Projects'

  Scenario: Resize browser window on User settings page and verify that User Menu dropdown appears and functions as expected
    Given I resize the browser window to various smaller sizes
    And I click on the User Menu icon
    Then I should see 'Profile', 'My Settings', and 'Logout'

#########################
# Mobile Testing - Manual testing
# Perform some manual tests on mobile devices/emulators and verify that navbar appears and functions as expected
#########################
