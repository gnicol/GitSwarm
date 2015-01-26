@team_management
Feature: Project Team Management
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And gitlab user "Mike"
    And I visit project "Shop" team page

  #########################
  # Receiving membership from the project owner through 'New project member' button.
  #########################

  # Scenario automated in features/project/team_management.feature and spec/lib/gitlab/git_access_spec.rb
  Scenario: Add a developer to a project and verify that developer is able to pull and push changes.
    Given ...

  Scenario: Add two developers to a project at the same time and verify that the developers are able to pull and push changes.
    Given ...

  # Scenario automated in features/project/team_management.feature
  Scenario: Click on the cancel button after inputting a user in the 'People' field on the "New project member(s)" page and verify that user is not added.
    Given ...

  @PGL-534
  Scenario: Attempt to add the project owner as a developer to a project and verify that project owner remains the project owner.
    Given ...

  @javascript @automated @PGL-537
  Scenario: Attempt to add a invalid user to a project and verify that 'No matches are found' and page remains the same
    Given I click link 'New project member'
    Then I should see the 'New project member(s)' page
    When I attempt to add a non-existent user in the People field
    Then I should see 'No matches found'
    When I click on the 'Add users' button
    Then I should still be on the 'New project member(s)' page

  @javascript @automated @PGL-537
  Scenario: Attempt to add '*$%&' in the user field where adding users in a project and verify that 'No matches are found' and page remains the same
    Given I click link 'New project member'
    Then I should see the 'New project member(s)' page
    When I attempt to add '*$%&' in the People field
    Then I should see 'No matches found'
    When I click on the 'Add users' button
    Then I should see the 'New project member(s)' page

  @javascript @automated @PGL-537
  Scenario: Attempt to add '@^!()' in the user field where adding users in a project and verify that 'No matches are found' and page remains the same
    Given I click link 'New project member'
    Then I should see the 'New project member(s)' page
    When I attempt to add '@^!()' in the People field
    Then I should see 'No matches found'
    When I click on the 'Add users' button
    Then I should see the 'New project member(s)' page

  #########################
  # Receiving membership from the project owner through 'Import members' button.
  #########################

  # Scenario automated in features/project/team_management.feature and spec/lib/gitlab/git_access_spec.rb
  Scenario: Import a developer to a project from a separate project and verify that developer is able to pull and push changes.
    Given ...

  @PGL-534
  Scenario: Import the same project into the project and verify that that user count and roles remain the same.
    Given ...

  Scenario: Click on the cancel button after selecting a project to import and verify that that user count and roles remain the same.
    Given ...


  #########################
  # Removing membership
  #########################

  Scenario: Remove a user from a project and verify that user cannot pull from the project
    Given ...