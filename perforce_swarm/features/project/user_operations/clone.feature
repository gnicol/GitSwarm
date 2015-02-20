@clone
Feature: Clone

  #########################
  # Private Project
  #########################

  Scenario: As a reporter/developer/master/owner of a private project, verify that user is able to clone the project.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'download_access_check'
    Given ...

  Scenario: As a guest of a private project, verify that user is NOT able to clone the project.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'download_access_check'  (Not specified in automated test whether public/internal/private)
    Given ...

  #########################
  # Public Project
  #########################

  Scenario: As a reporter/developer/master/owner of a public project, verify that user is able to clone the project.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'download_access_check'  (Not specified in automated test whether public/internal/private)
    Given ...

  Scenario: As a guest of a public project, verify that user is NOT able to clone the project.
    # Partially automated in spec/lib/gitlab/git_access_spec.rb; describe 'download_access_check'  (Not specified in automated test whether public/internal/private)
    Given ...
