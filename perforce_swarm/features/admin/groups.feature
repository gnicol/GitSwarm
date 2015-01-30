@admin
Feature: Admin Groups

  #########################
  # Receiving membership from an admin through a group
  #########################

  Scenario: As an admin, add a developer to a group in the 'Add user(s) to the group:' section of the Admin area and verify that developer is able to pull and push changes to the project.
  # Partially automated in features/admin/groups.feature; Scenario: Add user into projects in group
    Given ...

  Scenario: As an admin, add a reporter to a group in the 'Add user(s) to the group:' section of the Admin area and verify that reporter is NOT able to pull and push changes to the project.
  # Partially automated in features/admin/groups.feature; Scenario: Add user into projects in group
    Given ...

  Scenario: As an admin, attempt to add an invalid user to a group in the 'Add user(s) to the group:' section of the Admin area and verify that 'No matches are found'
    Given ...

  Scenario: As an admin, attempt to add special characters in the 'Add user(s) to the group:' section of the Admin area and verify that 'No matches are found'
    Given ...
