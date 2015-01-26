@admin
Feature: Admin Groups
  Background
    Given ...

  #########################
  # Receiving membership from an admin through a group
  #########################

  # Scenario partially automated in features/admin/group.feature
  Scenario: As an admin, add a developer to a group in the 'Add user(s) to the group:' section of the Admin area and verify that developer is able to pull and push changes to the project.
    Given ...

  Scenario: As an admin, attempt to add an invalid user to a group in the 'Add user(s) to the group:' section of the Admin area and verify that 'No matches are found'
    Given ...

  Scenario: As an admin, attempt to add special characters in the 'Add user(s) to the group:' section of the Admin area and verify that 'No matches are found'
    Given ...
