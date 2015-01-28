Feature: Project Merge Requests

  #########################
  # Creating Merge Requests
  #########################

  # These scenarios should be automated as assigned and unassigned

  Scenario: As a member of a project, from the dashboard activity feed I create a merge request from a dev branch to master.
    # Partially automated in features/dashboard/dashboard.feature; Scenario: I should see last push widget
    Given ...

  Scenario: As a member of a project, from the project activity feed I create a merge request from a dev branch to master.
    Given ...

  Scenario: As a member of a project, from the commits>branches page I create a merge request from a dev branch to master.
    Given ...

  Scenario: As a member of a project, from the merge request page I create a merge request from a dev branch to master.
    # Automated (kinda) in features/project/merge_requests.feature; Scenario: I submit new unassigned merge request
    Given ...

  Scenario: With a forked project, from the dashboard activity feed I create a merge request from the forked project to the source project.
    Given ...

  Scenario: With a forked project, from the project activity feed I create a merge request from the forked project to the source project.
    Given ...

  Scenario: With a forked project, from the merge request page I create a merge request from the forked project to the source project.
    # Automated in features/project/forked_merge_requests.feature; Scenario: I submit new unassigned merge request to a forked project
    Given ...

  #################################
  # Collaboration on Merge Requests
  #################################

  Scenario: As a reviewer of a merge request, I leave a comment in the discussion tab.
    # Automated (kinda) in features/project/merge_requests.feature; Scenario: I comment on a merge request
    # The automation does not check the role of the person commenting... by reviewer, I simple mean a user who is not the author of the merge request
    Given ...

  Scenario: As a reviewer of a merge request, I leave a comment on a diff.
    # Automated (kinda) in features/project/merge_requests.feature; Scenario: I comment on a merge request diff
    Given ...

  Scenario: As the author of a merge request, I reply to a comment left by a reviewer.
    Given ...

  Scenario: While creating a merge request, I add a participant to the review by at-mentioning another user in the description
    Given ...

  Scenario: Assign a user to an unassigned merge request.
    Given ...

  Scenario: Reassign a merge request.
    Given ...

  ############################
  # Accepting a Merge Requests
  ############################

  # There is one automated scenario that I could find dealing with accepting a merge request but it also creates a custom commit message.

  Scenario: As a reviewer of a merge request, I accept the merge request and concurrently delete the source branch.
    Given ...

  Scenario: As a reviewer of a merge request, I accept the merge request and don't delete the source branch.
    Given ...

  Scenario: As the reviewer of a merge request, I close the merge request.
    # Automated (kinda) in features/project/merge_requests.feature; Scenario: I close merge request page
    Given ...

