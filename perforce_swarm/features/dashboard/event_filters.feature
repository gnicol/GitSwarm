@dashboard
Feature: Event Filters
  Background:
    Given I sign in as a user
    And I own a project

  # These are test cases identified while testing the dashboard activity page

  ###############
  # Activity Feed
  ###############

  @automated @javascript
  Scenario: Create a comment on a merge request and verify that the comment event is shown in the activity feed
    Given this project has merge request event
    And this merge request has a comment
    When I visit dashboard page
    Then I should see comment event

  Scenario: Create an issue and verify that the opened issue event is shown in the activity feed
    # Automated in spec/features/atom/dashboard_spec.rb; it 'should have issue opened event'
    Given ...

  Scenario: Create a comment on an issue and verify that the issue comment event is shown in the activity feed
    # Automated in spec/features/atom/dashboard_spec.rb; it 'should have issue comment event'
    Given ...

  Scenario: With a merge request event, a push event, and a new member event, verify that all events are shown in the activity feed
    # Automated in features/dashbaord/event_filters.feature; Scenario: I should see all events
    Given ...

  Scenario: Push a change to a project and verify that the 'Create Merge Request' push widget is shown in the actiivity feed. When the 'Create Merge Request' button is clicked, verify that a prefilled new Merge Request page is shown
    # Automated in features/dashboard/dashboard.feature; I should see last push widget
    Given ...

  Scenario: Close an issue and verify that the closed issue event is shown in the activity feed
    # Similar test cases exist in spec/features/atom/dashboard_spec.rb
    Given ...

  Scenario: Open a merge request and verify that the new merge request event is shown in the activity feed
    # Similar test cases exist in spec/features/atom/dashboard_spec.rb
    Given ...

  Scenario: Close a merge request event and verify that the closed merge request event is shown in the activity feed
    # Similar test cases exist in spec/features/atom/dashboard_spec.rb
    Given ...

  Scenario: Leave a comment on a commit and verify that the comment on commit event is shown in the activity feed
    # Similar test cases exist in spec/features/atom/dashboard_spec.rb
    Given ...

  Scenario: Create a new branch and verify that the new branch event is shown in the activity feed
    Given ...

  Scenario: Delete a branch and verify that the branch delete event is shown in the activity feed
    Given ...

  Scenario: Hover over the timestamp of a commit event in the dashboard activity and verify that the tooltip appears
    Given ...

  ###############################
  # Username in the Activity Feed
  ###############################

  Scenario: As a user with name 'John Doe' join a project named 'Shop'. Verify that the 'John Doe joined project at Shop' event is shown in the activity feed
    # Automated in features/dashboard/dashboard.feature; Scenario: I should see User joined Project event
    Given ...

  Scenario: As User 'John Doe' leave project 'Shop' and verify that 'John Doe left project at Shop' event is shown in the activity feed
    # Similar test case is automated in features/dashboard/dashboard.feature
    Given ...

  Scenario: As user 'John Doe' create an issue and verify that 'John Doe opened issue...' is shown in the activity feed
    Given ...

  Scenario: As user 'John Doe' create a merge request and verify that 'John Doe opened merge request...' is shown in the activity feed
    Given ...

  Scenario: As user 'John Doe' push a commit and verify that 'John Doe pushed...' is shown in the activity feed
    Given ...

  Scenario: As user 'John Doe' comment on a merge request and verify that 'John Doe commented...' is shown in the activity feed
    Given ...

  Scenario: In the 'opened issue' event, click on the username (John Doe) and verify that you are navigated to the user's (John Doe) profile/activity page.
    Given ...

  #######################
  # Activity Feed Filters
  #######################

  Scenario: Click on the 'team' event filter, and verify that only team events (such as a member joined a project) are shown in the activity feed
    # Automated in features/dashboard/event_filters.feature; Scenario: I should see only joined events
    Given ...

  Scenario: Click on the 'merge' event filter and verify that only the 'merge' event is shown in the activity feed
    # Automated in features/dashboard/event_filters.feature; Scenario: I should see only merged events
    Given ...

  Scenario: With event filters applied ('push', 'team', 'comments', or 'merge requests'), refresh the page and verify that the filters persist
    # Automated in features/dashboard/event_filters.feature; Scenario: I should see only selected events while page reloaded
    Given ...

  Scenario: Click on the 'push' event filter and verify that only the push event is shown in the activity feed.
    # Partially automated in features/dashboard/event_filters.feature; Scenario: I should see only pushed events
    When the 'push' event filter is removed
    Then verify that all events are shown

  Scenario: With the 'team' event filter applied, remove the 'team' event filter and verify that all events are shown
    Given ...

  Scenario: With the 'merge request' event filter applied, remove the 'merge request' filter and verify that all events are shown
    Given ...

  Scenario: Click on the 'comments' event filter and verify that only the comment event is shown in the activity feed
    Given the 'comments' event filter is removed
    Then verify that all events are shown

  ############
  # Hyperlinks
  ############

  Scenario: In the new branch event, click on the branches hyperlink and verify that you are navigated to the branch commit page
    Given ...

  Scenario: Delete a branch and verify that there is no hyperlink to the branch in the branch delete event
    Given ...

  Scenario: With a deleted branch, click on a link to the deleted branch and verify error that branch has been deleted
    Given ...

  Scenario: With a project that has an issue #1, create a branch called '#1'. On the activity feed, click a link to the branch and verify that you navigate to the branch commit page.
    Given ...
