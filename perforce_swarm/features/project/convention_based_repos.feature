@project
Feature: Convention Based Repos

  #############################
  # Disabled/invalid configuration tests
  #############################

  @automated @javascript
  Scenario: Having Git Fusion disabled results in a disabled message and no radio button to select convention-based mirroring.
    Given I sign in as a user
    And Git Fusion support is disabled
    When I visit new project page
    Then I should see a Git Fusion is disabled message
    And I should not see a convention-based mirroring radio button

  @automated @javascript
  Scenario: Having a missing Git Fusion config results in a disabled message and no radio button to select convention-based mirroring.
    Given I sign in as a user
    And The Git Fusion config block is missing
    When I visit new project page
    Then I should see a Git Fusion is disabled message
    And I should not see a convention-based mirroring radio button

  @automated @javascript
  Scenario: Having a config with an invalid URL results in a disabled message and no radio button to select convention-based mirroring.
    Given I sign in as a user
    And The Git Fusion config block has a malformed URL
    When I visit new project page
    Then I should see a Git Fusion Configuration Error
    And I should not see a convention-based mirroring radio button

  @automated @javascript
  Scenario: With Git Fusion enabled, but otherwise having no config results in a disabled message and no radio button to select convention-based mirroring.
    Given I sign in as a user
    And Git Fusion is enabled but is otherwise not configured
    When I visit new project page
    Then I should see a Git Fusion Configuration Error
    And I should not see a convention-based mirroring radio button

  #############################
  # Convention-based mirroring unavailable (but mirroring existing possibly available)
  #############################
  @automated @javascript
  Scenario: With Git Fusion returning an empty list of managed repos, results in a disabled radio button to select convention-based mirroring.
    Given I sign in as a user
    And Git Fusion returns an empty list of managed repos
    When I visit new project page
    Then I should see a message saying Git Fusion has no repos available for import
    And I should not see a Git Fusion repo dropdown
    And I should see a disabled convention-based mirroring radio button

  @automated @javascript
  Scenario: With Git Fusion returning a list of repos, selecting one that does not have a valid convention-based mirroring configured results in a message telling me that convention-based mirroring is not available.
    Given I sign in as a user
    And Git Fusion returns a list containing repos without convention-based mirroring
    When I visit new project page
    And I select the default Git Fusion server
    Then I should see a populated Git Fusion server dropdown
    And I should see a disabled convention-based mirroring radio button
    And I should see a link to the convention-based mirroring help section

  @automated @javascript
  Scenario: With Git Fusion returning a list of repos, selecting one that has an invalid path_template results in a message telling me that convention-based mirroring is not available.
    Given I sign in as a user
    And Git Fusion returns a list containing repos with an invalid path_template
    When I visit new project page
    And I select the default Git Fusion server
    Then I should see a populated Git Fusion server dropdown
    And I should see a disabled convention-based mirroring radio button
    And I should see a link to the convention-based mirroring help section

  @automated @javascript
  Scenario: With Git Fusion returning a list of repos, selecting one that has a non-existent Perforce depot results in a message telling me that convention-based mirroring is not available.
    Given I sign in as a user
    And Git Fusion returns a list containing repos with a path_template referencing a non-existent Perforce depot
    When I visit new project page
    And I select the default Git Fusion server
    Then I should see a populated Git Fusion server dropdown
    And I should see a disabled convention-based mirroring radio button
    And I should see a link to the convention-based mirroring help section

  @automated @javascript
  Scenario: With Git Fusion returning a list of repos, selecting one that has the wrong Perforce credentials results in a message telling me that convention-based mirroring is not available, and shows the error message from Perforce.
    Given I sign in as a user
    And Git Fusion returns a list containing repos that have incorrect Perforce credentials
    When I visit new project page
    And I select the default Git Fusion server
    Then I should see a populated Git Fusion server dropdown
    And I should see a disabled convention-based mirroring radio button
    And I should see a link to the convention-based mirroring help section

  #############################
  # Convention-based mirroring available
  #############################
  @automated @javascript
  Scenario: With Git Fusion returning a list of repos with convention-based mirroring available, I should see a mirroring option to enable convention-based mirroring.
    Given I sign in as a user
    And Git Fusion returns a list containing repos
    When I visit new project page
    And I select the default Git Fusion server
    Then I should see a populated Git Fusion server dropdown
    And I should see a clickable convention-based mirroring radio button
    And I should see the correct P4D depot path for convention-based mirroring
