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
