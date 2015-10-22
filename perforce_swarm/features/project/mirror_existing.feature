@project
Feature: Mirror Existing Project
  @automated
  Scenario: Having Git Fusion disabled results in a disabled mirroring button, and a disabled/mis-configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is disabled
    When I visit project "Shop" page
    Then I should see a disabled Mirror in Helix button
    And I should see a disabled or mis-configured tooltip

  @automated 
  Scenario: Having Git Fusion config missing results in a disabled mirroring button, and a disabled/mis-configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And The Git Fusion config block is missing
    When I visit project "Shop" page
    Then I should see a disabled Mirror in Helix button
    And I should see a disabled or mis-configured tooltip

  @automated 
  Scenario: Having Git Fusion enabled with no configured Git Fusion servers results in a disabled mirroring button, and a no Git Fusion instances configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion is enabled but is otherwise not configured
    When I visit project "Shop" page
    Then I should see a disabled Mirror in Helix button
    And I should see a no Git Fusion instances configured tooltip

  @automated 
  Scenario: Having Git Fusion enabled, servers configured, but no servers with convention-based mirroring configured results in a disabled mirroring button, and a no Git Fusion instances configured with auto-create tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is enabled with no auto-create enabled servers
    When I visit project "Shop" page
    Then I should see a disabled Mirror in Helix button
    And I should see a no Git Fusion instances configured for auto-create tooltip

  @automated 
  Scenario: Having Git Fusion enabled, with auto-creation configured but no permissions to edit the project, results in a disabled mirroring button, and an inadequate permissions tooltip.
    Given I sign in as a user
    And I am not a member of project "Shop"
    And Git Fusion support is enabled with auto-create enabled servers
    When I visit project "Shop" page
    Then I should see a disabled Mirror in Helix button
    And I should see an inadequate permissions tooltip

  @automated 
  Scenario: Having Git Fusion enabled with mirroring configured and adequate permissions, but on an already-mirrored project results in the mirroring button not being displayed and "mirrored in helix" displayed below the clone URL field.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is enabled for project "Shop"
    When I visit project "Shop" page
    Then I should not see a Mirror in Helix button
    And I should see "mirrored in helix" under the clone URL field

  @automated 
  Scenario: Having Git Fusion enabled with mirroring configured and adequate permissions, on a non-mirrored project results in the mirroring button being displayed and "not mirrored in helix" displayed below the clone URL field.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is not enabled for project "Shop"
    When I visit project "Shop" page
    Then I should see a Mirror in Helix button
    And I should see "not mirrored in helix" under the clone URL field

  @automated @javascript
  Scenario: If I have an un-mirrored project ready to mirror, with one Git Fusion server that supports auto-create, I can click the Mirror in Helix button and be taken to the configure_mirroring view.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is enabled with auto-create enabled servers
    And I visit project "Shop" page
    When Click the Mirror in Helix button
    Then I should go to the Mirror in Helix page

  @automated @javascript
  Scenario: If I have an un-mirrored project ready to mirror, with multiple Git Fusion servers configured, but only one with auto-create, I can click the Mirror in Helix button and be taken to the configure_mirroring view and have the Git Fusion server with auto-create enabled be selected.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is enabled with auto-create enabled servers
    And I visit project "Shop" page
    When Click the Mirror in Helix button
    Then I should go to the Mirror in Helix page

#  @automated @javascript
#  Scenario: If I have an un-mirrored project ready to mirror, click the Mirror in Helix button, then disable auto-create and attempt to mirror the project, I am taken back to the configure_mirroring page and an alert is shown with an error message.

