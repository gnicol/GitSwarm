Feature: Project Merge Requests
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And project "Shop" has push event

  # The following are test cases identified when testing collaboration and reviews

  #########################
  # Creating Merge Requests
  #########################

  # Considering automating these test cases as both assigned and unassigned

  # To Do: Add more tests around group projects

  @automated
  Scenario: As a member of a project, from the dashboard activity feed I create an assigned merge request from a dev branch to master.
    # Partially automated in features/dashboard/dashboard.feature; Scenario: I should see last push widget
    Given I visit dashboard page
    Then I should see last push widget
    When I click "Create Merge Request" link
    And I see prefilled new Merge Request page
    And I click button "Assign to me"
    When I submit new merge request "Jira Integration"
    And I visit project "Shop" merge requests page
    Then I should see "Jira Integration" in merge requests

  Scenario: As a member of a project, from the project activity feed I create a merge request from a dev branch to master.
    Given ...

  Scenario: As a member of a project, from the commits>branches page I create a merge request from a dev branch to master.
    # To do
    Given ...

  Scenario: As a member of a project, from the merge request page I create an unassigned merge request from a dev branch to master.
    # Automated in features/project/merge_requests.feature; Scenario: I submit new unassigned merge request
    Given ...

  Scenario: With a forked project, from the dashboard activity feed I create a merge request from the forked project to the source project.
    Given ...

  Scenario: With a forked project, from the project activity feed I create a merge request from the forked project to the source project.
    Given ...

  Scenario: With a forked project, from the merge request page I create an unassigned merge request from the forked project to the source project.
    # Automated in features/project/forked_merge_requests.feature; Scenario: I submit new unassigned merge request to a forked project
    Given ...

  #################################
  # Collaboration on Merge Requests
  #################################

  Scenario: As a reviewer of a merge request, I leave a comment in the discussion tab.
    # Automated in features/project/merge_requests.feature; Scenario: I comment on a merge request
    # The automation is not explicit about the role (author, participant) of the person commenting
    Given ...

  Scenario: As a reviewer of a merge request, I leave a comment on a diff.
    # Automated (kinda) in features/project/merge_requests.feature; Scenario: I comment on a merge request diff
    Given ...

  Scenario: As the author of a merge request, I reply to a comment left by a reviewer.
    Given ...

  Scenario: While creating a merge request, I add a participant to the review by at-mentioning another user in the description
    Given ...

  Scenario: Assign a user to an unassigned merge request.
    # Partially automated in features/dashboard/merge_requests.feature; Scenario: I should see assigned merge_requests
    Given ...

  Scenario: Reassign a merge request.
    # Automated (as unit tests) in spec/models/merge_request_spec.rb; it 'returns true if the merge_request assignee has changed'
    Given ...

  ##########################
  # Accepting Merge Requests
  ##########################

  #To Do: Add tests around merging to a protected branch

  Scenario: I accept a merge request with custom commit message
    #Automated in features/project/merge_requests.feature; Scenario: I accept merge request with custom commit message
    Given ...

  Scenario: As a reviewer of a merge request, I accept the merge request and concurrently delete the source branch.
    Given ...

  @automated @javascript
  Scenario: As a reviewer of a merge request, I accept the merge request and don't delete the source branch.
    Given there is a gitlab user "Sam"
    And "Sam" is "Shop" developer
    When I visit my project's merge requests page
    And I click link "New Merge Request"
    And I fill out a "Compare branches for new Merge Request"
    And I submit new merge request "Dependency Fix"
    And merge request "Dependency Fix" is mergeable
    When I logout
    Then I should be redirected to sign in page
    When I sign in as "Sam"
    And I visit merge request page "Dependency Fix"
    And merge request is mergeable
    When I accept this merge request
    And I should see merged request
    When I visit project branches page
    Then I should see project branch "Fix"

  Scenario: As the reviewer of a merge request, I close the merge request.
    # Automated in features/project/merge_requests.feature; Scenario: I close merge request page
    # The automation is not explicit about the role (author, participant) of the person closing the merge request
    Given ...

  Scenario: As a member of a group project, I close a merge request.
    # To Do: use a group project and step through the actual processes of closing a merge request
    Given ...

  Scenario: As a user with Master permissions in a project with a protected branch, I accept a merge request from a dev branch to the protected branch.
    Given ...

  ##################
  # Compare Branches
  ##################

  # Add tests for the Compare branches for new merge requests?
