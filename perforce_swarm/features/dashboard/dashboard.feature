@dashboard
Feature: Dashboard

  # The following are test cases identified when testing the dashboard activity page
  Scenario: I should see project in list when filtered 
    Given I sign in as a user
    And I own project "Shop"
    And I visit dashboard page
    When I filter projects with "Shop"
    Then I should see project "Shop" in list 

  Scenario: I should not see project in list when filtered
    Given I sign in as a user
    And I own project "Shop"
    And I visit dashboard page
    When I filter projects with "Upcase"
    Then I should not see project "Shop" in list

  Scenario: I should see total projects
    Given I sign in as a user
    And I own project "Shop"
    And I own project "Upcase" 
    And I own project "Pygmie"
    When I visit dashboard page
    Then I should see 3 on the project tab

  Scenario: I should see total groups
    Given I sign in as a user
    And I have group with projects
    When I visit dashboard page
    Then I should see 1 on the group tab
