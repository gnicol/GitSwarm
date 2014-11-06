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

  # Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see last push widget
    Given project "Shop" has push event
    Then I should see last push widget
    And I click "Create Merge Request" link
    Then I see prefilled new Merge Request page

  #Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see User joined Project event
    Given user with name "John Doe" joined project "Shop"
    When I visit dashboard page
    Then I should see "John Doe joined project at Shop" event

  Scenario: I should see User left Project event
    Given user with name "John Doe" joined project "Shop"
    And user with name "John Doe" left project "Shop"
    When I visit dashboard page
    Then I should see "John Doe left project at Shop" event
