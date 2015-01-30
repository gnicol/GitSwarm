@admin
Feature: Admin Groups
  Background:
    Given ...

  #########################
  # Receiving membership from an admin through a group
  #########################

  Scenario: As an admin, add a developer to a group in the 'Add user(s) to the group:' section of the Admin area and verify that developer is able to pull and push changes to the project.
  # Partially automated in features/admin/groups.feature; Scenario: Add user into projects in group
    Given ...

  Scenario: As an admin, add a reporter to a group in the 'Add user(s) to the group:' section of the Admin area and verify that reporter is NOT able to pull and push changes to the project.
  # Partially automated in features/admin/groups.feature; Scenario: Add user into projects in group
    Given ...
