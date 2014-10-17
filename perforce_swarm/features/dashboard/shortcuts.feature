@dashboard
Feature: Dashboard Shortcuts

  # The following test cases were identified when testing the dashboard activity page
  Scenario: Navigate to activity tab
    Given I sign in as a user
    And I visit dashboard issues page
    When I press "g" "a"
    Then the active main tab should be Activity
