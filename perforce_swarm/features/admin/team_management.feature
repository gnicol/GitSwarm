@admin
Feature: Admin Team Management
  Background:
    Given ...

  #########################
  # Admin - Receiving membership from an admin
  #########################

  Scenario: As an admin, add a developer/master to a public/internal/private project by clicking on the "Manage Access" button in the Admin area of a project and verify that developer is able to pull and push changes.
  # Note:  Clicking on the "Manage Access" button takes admin to team management page, where the manual and automated tests are covered in features/project/team_management.feature.
    Given ...

  Scenario: As an admin, add a reporter to a public/internal/private project by clicking on the "Manage Access" button in the Admin area of a project and verify that reporter is NOT able to pull and push changes.
  # Note:  Clicking on the "Manage Access" button takes admin to team management page, where the manual and automated tests are covered in features/project/team_management.feature.
    Given ...