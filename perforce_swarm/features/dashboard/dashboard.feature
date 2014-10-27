@dashboard
Feature: Dashboard
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And I visit dashboard page

  # The following are test cases identified when testing the dashboard activity page
  Scenario: I should see project in list when filtered 
    Given I filter projects with "Shop"
    Then I should see project "Shop" in list 

  Scenario: I should not see project in list when filtered
    Given I filter projects with "Upcase"
    Then I should not see project "Shop" in list

  Scenario: I should see total projects
    Given I own 3 projects
    Then I should see 3 on the project tab

  Scenario: I should see total groups
    Given I click on the group tab
    Then I should see 1 on the group tab

  #Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see projects list
    Given project "Shop" has push event
    Then I should see "New Project" link
    Then I should see "Shop" project link
    Then I should see project "Shop" activity feed

  # Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see groups list
    Given I have group with projects
    And I visit dashboard page
    Then I should see groups list

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
