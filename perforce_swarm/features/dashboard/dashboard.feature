@dashboard
Feature: Dashboard
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And I visit dashboard page

  # The following are test cases identified when testing the dashboard activity page

  ############
  #Project tab
  ############

  #Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see projects list
    Given project "Shop" has push event
    Then I should see "New Project" link
    Then I should see "Shop" project link
    Then I should see project "Shop" activity feed

  Scenario: Filter projects with 'Shop' and verify that project 'Shop' is in the list
    Given foobar

  Scenario: Filter projects with 'Upcase' and verify that project 'Shop' is not in list
    Given foobar

  Scenario: As a user with 3 projects, verify that the project tab has '3' on it.
    Given foobar

  ##########
  #Group tab
  ##########

  # Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see groups list
    Given I have group with projects
    And I visit dashboard page
    Then I should see groups list

  Scenario: As a user with 1 group, verify that the group tab has '1' on it
    Given foobar
