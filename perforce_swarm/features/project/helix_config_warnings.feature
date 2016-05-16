@project
Feature: Helix Config Warnings

  @automated
  Scenario: With configuration warnings silenced, having Git Fusion disabled results in a disabled mirroring button, and a disabled/mis-configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is disabled
    And Helix configuration warnings are silenced
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should not see a disabled or mis-configured tooltip

  @automated
  Scenario: With configuration warnings silenced, having Git Fusion config missing results in a disabled mirroring button, and a disabled/mis-configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And The Git Fusion config block is missing
    And Helix configuration warnings are silenced
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a disabled or mis-configured tooltip

  @automated
  Scenario: Having Git Fusion enabled with no configured Git Fusion servers results in a disabled mirroring button, and a no Git Fusion instances configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion is enabled but is otherwise not configured
    And Helix configuration warnings are silenced
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a no Git Fusion instances configured tooltip

  @automated
  Scenario: Having Git Fusion enabled, servers configured, but no servers with convention-based mirroring configured results in a disabled mirroring button, and a no Git Fusion instances configured with auto-create tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is enabled with no auto-create enabled servers
    And Helix configuration warnings are silenced
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a no Git Fusion instances configured for auto-create tooltip