@admin
Feature: Admin Settings
  Background:
    Given I sign in as an admin
    And I visit admin settings page

  Scenario: See email on push settings
    When I click on "Service Templates"
    And I click on "Emails on push" service
    Then I can see field help text like "part of the domain GitSwarm"
