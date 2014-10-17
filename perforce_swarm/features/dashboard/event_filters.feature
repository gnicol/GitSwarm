@dashboard
Feature: Event Filters

  # These are test cases identified while testing the dashboard activity page 
  @automated @javascript
  Scenario: I should see comment event
    Given I sign in as a user
    And I own a project
    And this project has merge request event
    And this merge request has a comment
    When I visit dashboard page
    Then I should see comment event

  Scenario: I should see timestamp tooltip
    Given I sign in as a user
    And I own a project
    And this project has a commit
    And I visit dashboard page
    When I hover over the timestamp
    Then I should see the timestamp tooltip

  Scenario: I should see all events without "push" event filter
    Given I sign in as a user
    And I own a project
    And this project has a merge request event
    And this merge request has a comment 
    And this project has a new member event
    And this project has a push event
    And I visit dashboard page
    And I click "push" event filter
    And I should see only pushed events
    When I click "push" event filter
    Then I should see all events

  Scenario: I should see all events without "team" event filter
    Given I sign in as a user
    And I own a project
    And this project has a merge request event
    And this merge request has a comment
    And this project has a new member event
    And this project has a push event
    And I visit dashboard page
    And I click "team" event filter
    And I should see only pushed events
    When I click "team" event filter
    Then I should see all events

  Scenario: I should see all events without "merge request" event filter
    Given I sign in as a user
    And I own a project
    And this project has a merge request event
    And this merge request has a comment
    And this project has a new member event
    And this project has a push event
    And I visit dashboard page
    And I click "merge request" event filter
    And I should see only merge request events
    When I click "merge request" event filter
    Then I should see all events

  Scenario: I should see only comment events
    Given I sign in as a user
    And I own a project
    And this project has a merge request event
    And this merge request has a comment
    And this project has a new member event
    And this project has a push event
    And I visit dashboard page
    When I click "comments" event filter
    Then I should see comment event
    And I should not see merge request event
    And I should not see new member event
    And I should not see push event

  Scenario: I should see all events without "comments" event filter
    Given I sign in as a user
    And I own a project
    And this project has a merge request event
    And this merge request has a comment
    And this project has a new member event
    And this project has a push event
    And I visit dashboard page
    And I click "comments" event filter
    And I should see only comment events
    When I click "comments" event filter
    Then I should see all events

  # Similar test cases exist in rspec
  Scenario: I should see closed issue event
    Given I sign in as a user
    And I own a project
    And this project has an issue
    And this issue is closed
    When I visit dashboard page
    Then I should see closed issue event

  # Similar test cases exist in rspec
  Scenario: I should see the new merge request event
    Given I sign in as a user
    And I own a project
    And I create a new merge request event
    When I visit the dashboard page
    Then I should see open merge request event

  # Similar test cases exist in rspec
  Scenario: I should see the closed merge request event
    Given I sign in as a user 
    And I own a project
    And I create a new merge request event
    And I close the merge request
    When I visit the dashboard page
    Then I should see closed merge request event

  # Similar test cases exist in rspec
  Scenario: I should see the commit comment event
    Given I sign in as a user
    And I own a project
    And this project has a push event
    And this commit has a comment
    When I visit the dashboard page
    Then I should see comment on commit event

