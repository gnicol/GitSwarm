@team_management
Feature: Project Team Management
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And gitlab user "Mike"
    And I visit project "Shop" team page

  #########################
  # Receiving membership from the project owner through "New project member' button.
  #########################

  Scenario: Add a developer to a public/internal/private project and verify that developer is able to pull and push changes.
  # Automated in features/project/team_management.feature; Scenario: Add user to project
  # and in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check'
    Given ...

  Scenario: Add two developers to a public/internal/private project at the same time and verify that the developers are able to pull and push changes.
    Given ...

  Scenario: Click on the cancel button after inputting a user in the 'People' field on the "New project member(s)" page and verify that user is not added.
  # Automated in features/project/team_management.feature; Scenario: Cancel team member
    Given ...

  @PGL-534
  Scenario: Attempt to add the project owner as a developer to a public/internal/private project and verify that project owner remains the project owner.
    Given ...

  @javascript @automated @PGL-537
  Scenario: Attempt to add a invalid user to a public/internal/private project and verify that "No matches are found" and page remains the same.
    Given I click the button "Add members"
    Then I should see the "New project member(s)" form
    When I attempt to add a non-existent user in the People field
    Then I should see "No matches found"
    When I click on the "Add users" button
    Then I should still be on the "New project member(s)" form

  @javascript @automated @PGL-537
  Scenario: Attempt to add '*$%&^!()' in the user field where adding users in a public/internal/private project and verify that 'No matches are found' and page remains the same.
    Given I click the button "Add members"
    Then I should see the "New project member(s)" form
    When I attempt to add "*$%&^!()" in the People field
    Then I should see "No matches found"
    When I click on the "Add users" button
    Then I should see the "New project member(s)" form

  #########################
  # Receiving membership from the project owner through 'Import members' button.
  #########################

  Scenario: Import a developer to a public/internal/private project from a separate project and verify that developer is able to pull and push changes.
  # Automated in features/project/team_management.feature; Scenario: Import team from another project
  # and in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check'
    Given ...

  @PGL-534
  Scenario: Import the same project into your own public/internal/private project and verify that that user count and roles remain the same.
    Given ...

  Scenario: Click on the cancel button after selecting a public/internal/private project to import and verify that that user count and roles remain the same.
    Given ...

  #########################
  # Removing membership
  #########################

  @javascript @automated
  Scenario: Remove a user from a public/internal/private project and verify that user cannot pull from the project
  # 'verify that user cannot pull from the project' is automated in spec/lib/gitlab/git_access_spec.rb; describe 'without access to project'
    Given gitlab user "Sam"
    And "Sam" is "Shop" developer
    And I visit project "Shop" team page
    Then I should see "Sam" in team list
    When I click cancel link for "Sam"
    And I visit project "Shop" team page
    Then I should not see "Sam" in team list
