@browse_files
Feature: Project Source Browse Files

  #########################
  # UI-Related (Navigate to the files/commits page view of a project)
  #########################

  Scenario: As a developer/master/owner, make edits to a file of a unprotected branch on the UI and "Commit Changes."
    # Partially automated in features/project/source/browse_files.feature; Scenario: I can edit file and commit file
    Given ...
    # Verify that user receives, "Your changes have been successfully committed" message.

  Scenario: As a guest/reporter, navigate to a file page on the UI and verify that "Edit" button is disabled
    Given ...

  Scenario: As a developer/master/owner, create a branch through the UI, push edits to the branch, and verify that changes are pushed successfully.
    Given ...
