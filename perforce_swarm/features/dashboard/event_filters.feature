@dashboard
Feature: Event Filters
  Background: 
    Given I sign in as a user
    And I own a project
    
  # These are test cases identified while testing the dashboard activity page 
  ##############
  #Activity Feed
  ##############

  @automated @javascript
  Scenario: I should see comment event
    Given this project has merge request event
    And this merge request has a comment
    When I visit dashboard page
    Then I should see comment event

  # Scenario automated in spec/features/atom/dashboard_spec.rb
  Scenario: I should see opened issue event
    Given this project has an issue
    When I visit dashboard page
    Then I should see opened issue event

  # Scenario automated in spec/features/atom/dashboard_spec.rb
  Scenario: I should see issue comment event
    Given this project has an issue
    And this issue has a comment
    When I visit dashboard page
    Then I should see issue comment event

  # Scenario automated in features/dashbaord/event_filters.feature
  Scenario: I should see all events
    Given this project has push event
    And this project has new member event
    And this project has merge request event
    When I visit dashboard page
    Then I should see push event
    And I should see new member event
    And I should see merge request event

  # Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see last push widget
    Given I own a project "Shop"
    And project "Shop" has push event
    Then I should see last push widget
    And I click "Create Merge Request" link
    Then I see prefilled new Merge Request page
   
  # Scenario automated in features/dashboard/dashboard.feature
  Scenario: I should see User joined Project event
    Given I own a project "Shop"
    And user with name "John Doe" joined project "Shop"
    When I visit dashboard page
    Then I should see "John Doe joined project at Shop" event
    
  # Similar test case is automated in features/dashboard/dashboard.feature
  Scenario: User 'John Doe' left project 'Shop', verify that 'John Doe left project at Shop' event is shown in the activity feed
    Given foobar

  # Similar test cases exist in spec/features/atom/dashboard_spec.rb
  Scenario: Close an issue and verify that the closed issue event is shown in the activity feed
    Given foobar

  # Similar test cases exist in spec/features/atom/dashboard_spec.rb
  Scenario: Open a merge request and verify that the new merge request event is shown in the activity feed
    Given foobar
    
  # Similar test cases exist in spec/features/atom/dashboard_spec.rb
  Scenario: Close a merge request event and verify that the closed merge request event is shown in the activity feed
    Given foobar

  # Similar test cases exist in spec/features/atom/dashboard_spec.rb 
  Scenario: Leave a comment on a commit and verify that the comment on commit event is shown in the activity feed
    Given foobar

  Scenario: Create a new branch and verify that the new branch event is shown in the activity feed
    Given foobar

  Scenario: Delete a branch and verify that the branch delete event is shown in the activity feed
    Given foobar
    
  Scenario: Hover over the timestamp of a commit event in the dashboard activity and verify that the tooltip appears
    Given foobar

  ######################
  #Activity Feed Filters
  ######################

  # Scenario automated in features/dashboard/event_filters.feature
  Scenario: I should see all events
    Given this project has push event
    And this project has new member event
    And this project has merge request event
    When I visit dashboard page
    Then I should see push event
    And I should see new member event
    And I should see merge request event

  # Scenario automated in features/dashboard/event_filters.feature
  Scenario: I should see only pushed events
    Given this project has push event
    And this project has new member event
    And this project has merge request event
    And I visit dashboard page
    When I click "push" event filter
    Then I should see push event
    And I should not see new member event
    And I should not see merge request event

  # Scenario automated in features/dashboard/event_filters.feature
  Scenario: I should see only joined events
    Given this project has push event
    And this project has new member event
    And this project has merge request event
    And I visit dashboard page
    When I click "team" event filter
    Then I should see new member request event
    And I should not see push event
    And I should not see merge request event

  # Scenario automated in features/dashboard/event_filters.feature
  Scenario: I shoul see only merged events
    Given this project has push event
    And this project has new member event
    And this project has merge request event
    And I visit dashboard page
    When I click "merge" event filter
    Then I should see merge request event
    And I should not see push event
    And I should not see new member event

  # Scenario automated in features/dashboard/event_filters.feature
  Scenario: I should see only selected events while page reloaded
    Given this project has push event
    And this project has new member event
    And this project has merge request event
    And I visit dashboard page
    When I click "push" event filter
    And I visit dashboard page
    When I should see push event
    And I should not see new member event
    When I click "team" event filter
    And I visit dashboard page
    Then I should see push event
    And I should see new member event
    And I should not see merge request event
    When I click "push"event filter
    Then I should not see push event
    And I should see new member event
    And I should not see merge request event

  Scenario: With a merge request event, a comment event, a new member event, and a push event click on the 'push' event filter and verify that only the push event is shown in the activity feed.
    When the 'push' event filter is removed
    Then verify that all events are shown

  Scenario: With the 'team' event filter applied, remove the 'team' event filter and verify that all events are shown
    Given foobar

  Scenario: With the 'merge request' event filter applied, remove the 'merge request' filter and verify that all events are shown
    Given foobar

  Scenario: Click on the 'comments' event filter and verify that only the comment event is shown in the activity feed
    Given the 'comments' event filter is removed
    Then verify that all events are shown

  ###########
  #Hyperlinks
  ###########

  Scenario: In the new branch event, click on the branches hyperlink and verify that you are navigated to the branch commit page
    Given foobar

  Scenario: Delete a branch and verify that there is no hyperlink to the branch in the branch delete event
    Given foobar

  Scenario: With a deleted branch, click on a link to the deleted branch and verify error that branch has been deleted
    Given foobar

  Scenario: With a projec that has an issue #1, create a branch called '#1'. On the activity feed, click a link to the branch and verify that you navigate to the branch commit page.
    Given foobar
