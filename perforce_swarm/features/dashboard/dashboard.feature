@dashboard
Feature: Dashboard

  # The following are test cases identified when testing the dashboard activity page

  #############
  # Project tab
  #############

  Scenario: As a user who is a member or owner of 2 projects ("Shop" and "New Project"), verify that the project list in the project tab contains a link to both projects
    # Automated in features/dashboard/dashboard.feature; Scenario: I should see projects list
    Given ...

  Scenario: Filter projects and verify that the following searches work:
    Given case sensitivity
    Given partial strings
    Given incorrect project names
    # | Filter | Verification                  |
    # case sensitivity search
    # | 'Shop' | Should see project 'Shop'     |
    # | 'shop' | Should see project 'Shop'     |
    # working partial string search
    # | 's'    | Should see project 'Shop'     |
    # | 'sh'   | Should see project 'Shop'     |
    # | 'sho'  | Should see project 'Shop'     |
    # non-working partial string search
    # | 'o'    | Should not see project 'Shop' |
    # | 'oh'   | Should not see project 'Shop' |
    # | 'ohp'  | Should not see project 'Shop' |
    # incorrect project name
    # | 'mop'  | Should not see project 'Shop' |

  Scenario: As a user with 3 projects, verify that the project tab has '3' on it.
    Given ...

  ###########
  # Group tab
  ###########

  Scenario: As a user with groups that have projects ("Group1" and "Group2"), verify that the groups list contains a link to both groups
    # Automated in features/dashboard/dashboard.feature; Scenario: I should see groups list
    Given ...

  Scenario: As a user with 1 group, verify that the group tab has '1' on it
    Given ...
