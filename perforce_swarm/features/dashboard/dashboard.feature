@dashboard
Feature: Dashboard

  # The following are test cases identified when testing the dashboard activity page

  ############
  #Project tab
  ############

   Scenario: As a user with 2 non-empty projects ("Shop" and "New Project"), verify that the project list in the project tab contains a link to both projects
    # Automated in features/dashboard/dashboard.feature; Scenario: I should see projects list
    Given ...

  Scenario: Filter projects with 'Shop' and verify that project 'Shop' is in the list
    Given ...

  Scenario: Filter projects with 'Upcase' and verify that project 'Shop' is not in list
    Given ...

  Scenario: As a user with 3 projects, verify that the project tab has '3' on it.
    Given ...

  ##########
  #Group tab
  ##########

   Scenario: As a user with groups that have projects ("Group1" and "Group2"), verify that the groups list contains a link to both groups
    # Automated in features/dashboard/dashboard.feature; Scenario: I should see groups list
    Given ...

  Scenario: As a user with 1 group, verify that the group tab has '1' on it
    Given ...
