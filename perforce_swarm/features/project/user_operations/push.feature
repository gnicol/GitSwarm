@push
Feature: Push

  #########################
  # Private Project - Ability to contribute code changes to a project.
  #########################

  Scenario: As a developer/master/owner, push changes to an unprotected branch of a private project, and verify that changes are pushed successfully.
    # Automated in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check'  (Not specified in automated test whether public/internal/private)
    Given ...
    # Verify that developer/master/owner is able to push commits into repo on the command line.
    # Verify that on the Dashboard, activity shows that code changes were committed.
    # Verify that the commit displays on a commit page with correct commit number, author, file, and messaging.

  Scenario: As a guest/reporter, attempt to push changes to an unprotected branch of a private project, and verify that user is NOT able to.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check'
    Given ...
    # Verify that guest/reporter is NOT able to push commits into the repo on the command line and receives, "GitLab: You don't have permission"

  Scenario: As a developer/master/owner of a private project, push a task branch and verify that branch is pushed successfully.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check' (Not specified in automated test whether public/internal/private)
    Given ...
    # Verify that developer/master/owner is able to push the task branch.
    # Verify that on the Dashboard, activity shows "User pushed new branch"'
    # Verify that the new branch page is created

  Scenario: As a guest/reporter of a private project, attempt to push a task branch and verify that user is NOT able to push branch to the project.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check' (Not specified in automated test whether public/internal/private)
    Given ...
    # Verify that guest/reporter is NOT able to push commits into the repo on the command line and receives, "GitLab: You don't have permission"

  #########################
  # Public Project - Ability to contribute code changes to a project.
  #########################

  Scenario: As a developer/master/owner, push changes to an unprotected branch of a public project, and verify that changes are pushed successfully.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check' (Not specified in automated test whether public/internal/private)
    Given ...
    # Verify that developer/master/owner is able to push commits into repo on the command line.
    # Verify that on the Dashboard, activity shows that code changes were committed.
    # Verify that the #commit displays on a commit page with correct commit number, author, file, and messaging.

  Scenario: As a developer/master/owner of a public project, push a task branch and verify that branch is pushed successfully.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'push_access_check' (Not specified in automated test whether public/internal/private)
    Given ...
    # Verify that developer/master/owner is able to push the task branch.
    # Verify that on the Dashboard, activity shows "User pushed new branch"'
    # Verify that the new branch page is created
