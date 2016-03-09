@project
Feature: Mirror Existing Project

  @automated
  Scenario: Having Git Fusion disabled results in a disabled mirroring button, and a disabled/mis-configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is disabled
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a disabled or mis-configured tooltip

  @automated 
  Scenario: Having Git Fusion config missing results in a disabled mirroring button, and a disabled/mis-configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And The Git Fusion config block is missing
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a disabled or mis-configured tooltip

  @automated 
  Scenario: Having Git Fusion enabled with no configured Git Fusion servers results in a disabled mirroring button, and a no Git Fusion instances configured tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion is enabled but is otherwise not configured
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a no Git Fusion instances configured tooltip

  @automated 
  Scenario: Having Git Fusion enabled, servers configured, but no servers with convention-based mirroring configured results in a disabled mirroring button, and a no Git Fusion instances configured with auto-create tooltip.
    Given I sign in as a user
    And I own project "Shop"
    And Git Fusion support is enabled with no auto-create enabled servers
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see a no Git Fusion instances configured for auto-create tooltip

  @automated 
  Scenario: Having Git Fusion enabled, with auto-creation configured but no permissions to edit the project, results in a disabled mirroring button, and an inadequate permissions tooltip.
    Given I sign in as a user
    And I am not a member of project "Shop"
    And Git Fusion support is enabled with auto-create enabled servers
    When I visit project "Shop" page
    Then I should see a disabled Helix Mirroring button
    And I should see an inadequate permissions tooltip

  @automated 
  Scenario: Having Git Fusion enabled with mirroring configured and adequate permissions, but on an already-mirrored project results in the mirroring button displayed and "Mirrored in Helix displayed below the clone URL field.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is enabled for project "Shop"
    When I visit project "Shop" page
    Then I should see a Helix Mirroring button
    And I should see "Mirrored in Helix" under the clone URL field

  @automated 
  Scenario: Having Git Fusion enabled with mirroring configured and adequate permissions, on a non-mirrored project results in the mirroring button being displayed and "Not Mirrored in Helix displayed below the clone URL field.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is not enabled for project "Shop"
    When I visit project "Shop" page
    Then I should see a Helix Mirroring button
    And I should see "Not Mirrored in Helix" under the clone URL field

  @automated
  Scenario: With Git Fusion mirroring configured, clicking the Helix Mirroring button takes me to the Helix Mirroring view.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is not enabled for project "Shop"
    And I visit project "Shop" page
    When I click the Helix Mirroring button
    Then I should be on the Helix Mirroring page for the "Shop" project

  @automated
  Scenario: If there are multiple Git Fusion servers to choose from, but only one has auto_create enabled, the one with auto_create is selected by default.
    Given I sign in as a user
    And Git Fusion support is enabled with one auto-create enabled server, but with multiple servers
    And Helix mirroring is not enabled for project "Shop"
    And I visit project "Shop" page
    When I click the Helix Mirroring button
    Then I should be on the Helix Mirroring page for the "Shop" project
    And The Git Fusion repo selected by default is the first one that has auto_create enabled

  @automated @javascript
  Scenario: On the Helix Mirroring page, selecting a Git Fusion repo that does not support auto-create, and error message is displayed.
    Given I sign in as a user
    And Git Fusion support is enabled with one auto-create enabled server, but with multiple servers
    And Helix mirroring is not enabled for project "Shop"
    And I visit project "Shop" page
    And I click the Helix Mirroring button
    When The Git Fusion depot path info is done loading
    And I select a Git Fusion repo with an resolvable hostname
    And The Git Fusion depot path info is done loading
    Then I should see an error message that says there was an error communicating with Helix Git Fusion

  @automated @javascript
  Scenario: On the Helix Mirroring page, selecting a Git Fusion repo that does not support auto-create, and error message is displayed.
    Given I sign in as a user
    And Git Fusion support is enabled with one auto-create enabled server, but with multiple servers
    And Helix mirroring is not enabled for project "Shop"
    And I visit project "Shop" page
    And I click the Helix Mirroring button
    When The Git Fusion depot path info is done loading
    And I select a Git Fusion repo that does not support auto-create
    And The Git Fusion depot path info is done loading
    Then I should see an error message that says auto-create is not configured properly

  @automated
  Scenario: On the Helix Mirroring page, for an already-mirrored project, I should see a Disable Helix Mirroring button.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is enabled for project "Shop"
    And I visit project "Shop" page
    And I click the Helix Mirroring button
    Then I should see the Disable Helix Mirroring button

  @automated
  Scenario: On the project details page, for a previously-mirrored project, I should see a "Click to re-enable mirroring" tooltip.
    Given I sign in as a user
    And Git Fusion support is enabled with auto-create enabled servers
    And Helix mirroring is disabled, but was once enabled for project "Shop"
    And I visit project "Shop" page
    Then The tooltip should say "Click to re-enable mirroring"
