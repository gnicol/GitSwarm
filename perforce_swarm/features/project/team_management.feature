@team_management
Feature: Project Team Management
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And gitlab user "Mike"
    And I visit project "Shop" team page

  @javascript @automated @PGL-537
  Scenario: Attempt to add a invalid user to a project and verify that 'No matches are found' and application does not add invalid user
    Given I click link 'New Team Member'
    And I attempt to add a non-existent user in the People field
    Then I should see 'No matches found'
    When I click on the 'Add users' button
    Then I should still be on the 'New project member(s)' page

  @javascript @automated @PGL-537
  Scenario: Attempt to add '*$%&' in the user field where adding users in a project and verify that 'No matches are found' and page remains the same
    Given I click link 'New Team Member'
    And I attempt to add '*$%&' in the People field
    Then I should see 'No matches found'
    When I click on the 'Add users' button
    Then I should still be on the 'New project member(s)' page

  @javascript @automated @PGL-537 @test
  Scenario: Attempt to add '@^!()' in the user field where adding users in a project and verify that 'No matches are found' and page remains the same
    Given I click link 'New Team Member'
    And I attempt to add '@^!()' in the People field
    Then I should see 'No matches found'
    When I click on the 'Add users' button
    Then I should still be on the 'New project member(s)' page