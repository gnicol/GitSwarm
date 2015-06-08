@dashboard
Feature: Check for updates
############################## Current tests and open issues on version check feature from the community site: ##############################
# Version check doesn't handle none git installations: https://gitlab.com/gitlab-org/gitlab-ce/issues/1416
# Version Check image alternative text is useless: https://gitlab.com/gitlab-org/gitlab-ce/issues/1684
# ( should not be relevant to our product, since we don't use the image for rendering)
# Version info spec test: spec/lib/gitlab/version_info_spec.rb (tests how Gitlab versioning is done, and how a succeeding version is counted to 
# be different from a previous one. Not directly relevant to us
# since we have a different versioning scheme, but might be useful for adding in similar unit tests)
###############################################################################################################################################


  #######################
  # System level tests
  #######################

  #  An omnibus build contains information regarding the major revision, minor revision, build number and the OS Platform.
  #  For example, for the build 'GitSwarm 2015.1-beta', 2015 is the major revision,'1'
  #  is the minor revision, and 'beta' is the build number. 'Build' can have a numbered value or have the values 'alpha' or 'beta'
  #  For the same major and minor revisions, a numbered revision attempting to upgrade from a beta release would have the value '

  @automated
  Scenario: With no matching platform in the versions file, no growl is shown
    Given I sign in as an admin
    And Check for updates is enabled
    And There is no matching platform in the versions file
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: With an unsupported platform value, no growl is shown
    Given I sign in as an admin
    And Check for updates is enabled
    And VersionCheck is set to an unsupported platform
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: With the platform set to noarch, no growl is shown
    Given I sign in as an admin
    And Check for updates is enabled
    And VersionCheck has a platform of noarch
    When I visit dashboard page
    Then I should not see a check for updates growl

  Scenario: A daily sidetiq task on the server handles the 'check for version update' logic. Verify that the sidetiq task works correctly based on its its set interval
    ## Tested the async sidetiq by setting its timeout to minutely and seeing that the "Version check banner was seen for a version update
    Given ...

  ######################
  # Basic work-flow tests
  ######################

  @automated
  Scenario: Check for updates is set to nil by default
    Given I sign in as an admin
    When I visit dashboard page
    Then I should see a check for updates growl
    Then I should be prompted to enable or disable check for updates

  @automated
  Scenario: Enabling check for updates via the admin settings page results in the growl being shown
    Given I sign in as an admin
    And I visit admin settings page
    And I enable check for updates and save the form
    And Am behind the next minor version of GitSwarm
    When I visit dashboard page
    Then I should see a check for updates growl
    Then I should be notified that my version is out of date
    Then I should be asked if I want to ignore this update

  @automated
  Scenario: Disabling check for updates via the admin settings page results in no growl being shown on an out of date install
    Given I sign in as an admin
    And I visit admin settings page
    And I disable check for updates and save the form
    And Am behind the next minor version of GitSwarm
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: GitSwarm admin receives an out of date growl if they are out of date by at least one major version
    Given I sign in as an admin
    And Check for updates is enabled
    And Am behind the next major version of GitSwarm
    When I visit dashboard page
    Then I should see a check for updates growl
    Then I should be notified that my version is out of date
    Then I should be asked if I want to ignore this update

  @automated
  Scenario: GitSwarm admin receives an out of date growl if they are out of date by at least one minor version
    Given I sign in as an admin
    And Check for updates is enabled
    And Am behind the next minor version of GitSwarm
    When I visit dashboard page
    Then I should see a check for updates growl
    Then I should be notified that my version is out of date
    Then I should be asked if I want to ignore this update

  @automated
  Scenario: GitSwarm admin receives an out of date growl if they are out of date by at least one build version
    Given I sign in as an admin
    And Check for updates is enabled
    And Am behind the next build version of GitSwarm
    When I visit dashboard page
    Then I should see a check for updates growl
    Then I should be notified that my version is out of date
    Then I should be asked if I want to ignore this update

  @automated
  Scenario: Clicking yes to allow check for updates enables the check for updates feature
    Given I sign in as an admin
    And Check for updates status is unknown
    And I click yes to allow check for updates
    Then I should see application settings saved
    Then Version check enabled checkbox is checked

  @automated
  Scenario: Clicking no to disable the check for updates unchecks the box on the settings page
    Given I sign in as an admin
    And Check for updates status is unknown
    And I click no to disable check for updates
    Then I should see application settings saved
    Then Version check enabled checkbox is not checked

  @automated
  Scenario: Admin will receive critical update only if 'critical: true' flag is set for the particular platform in the JSON file
    Given I sign in as an admin
    And Check for updates is enabled
    And Am behind the next minor version of GitSwarm
    And The next version is a critical update
    When I visit dashboard page
    Then I should be notified that my version is out of date
    Then I should be notified of a critical update
    Then I should be asked if I want to ignore this update

  #########################
  # Front-end verifications
  #########################

  # Check for updates is in unknown state
  @automated
  Scenario: Growl notification should be displayed if an admin views the dashboard and has not chosen to en/disable check for updates
    Given I sign in as an admin
    And Set check for updates status to unknown
    When I visit dashboard page
    Then I should see a check for updates growl
    Then I should be prompted to enable or disable check for updates

  @automated
  Scenario: Growl notifications should not be displayed for regular users when check for updates has not been en/disabled
    Given I sign in as a user
    And Set check for updates status to unknown
    When I visit dashboard page
    Then I should not see a check for updates growl

  # Check for updates has been enabled
  @automated
  Scenario: The update revision feature should work if an admin signs in for the first time on an existing GitSwarm server, after the version check feature is enabled
    Given I sign in as an admin
    And Check for updates is enabled
    And Am behind the next minor version of GitSwarm
    When I visit dashboard page
    Then I should see a check for updates growl

  @automated
  Scenario: My release is equal to or ahead of the current available release, I should see no growl on the dashboard
    Given I sign in as an admin
    And Check for updates is enabled
    And My GitSwarm install is up to date
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: The list of available versions contains a malformed version, that version is ignored
    Given I sign in as an admin
    And Check for updates is enabled
    And My GitSwarm install is up to date
    And There is a malformed version in the list of available versions
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: No update is available but the latest version is marked as critical, I should see no growl on the dashboard
    Given I sign in as an admin
    And Check for updates is enabled
    And My GitSwarm install is up to date
    And The current version is a critical update
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated @javascript
  Scenario: I can click on the X in the growl message, which sets the dismiss_version_check cookie and removes the growl
    Given I sign in as an admin
    And Check for updates is enabled
    And Am behind the next minor version of GitSwarm
    And I visit dashboard page
    When I click the X to close the growl
    Then I should not see a check for updates growl
    Then The dismiss_version_check cookie should be set

  # Check for updates has been disabled
  @automated
  Scenario: No growl should be shown if check for updates is disabled
    Given I sign in as an admin
    And Disable check for updates
    And Am behind the next minor version of GitSwarm
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: With check for updates disabled, when my release is equal to or ahead of the current available release, I should see no growl on the dashboard
    Given I sign in as an admin
    And Disable check for updates
    And My GitSwarm install is up to date
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: With check for updates disabled, when the list of available versions contains a malformed version, that version is ignored
    Given I sign in as an admin
    And Disable check for updates
    And My GitSwarm install is up to date
    And There is a malformed version in the list of available versions
    When I visit dashboard page
    Then I should not see a check for updates growl

  @automated
  Scenario: With check for updates disabled, when no update is available but the latest version is marked as critical, I should see no growl on the dashboard
    Given I sign in as an admin
    And Disable check for updates
    And My GitSwarm install is up to date
    And The current version is a critical update
    When I visit dashboard page
    Then I should not see a check for updates growl

  ### in addition to checking that no banner appears, confirm that the customer is also not pulling the version check file from the external URL??

  # As an admin who has not confirmed whether or not they would like to receive update notifications (version_check is set to null):
  ## when an update (major/minor/build) is available, if I navigate to the homepage I should see a yellow banner that says "This Installation of GitSwarm is out of date. An update is available. Allow GitSwarm to keep checking for updates?"
  ## when a critical update (major/minor/build) is available, if I navigate to the homepage I should see a red banner that says "This Installation of GitSwarm is out of date. A critical update is available. Allow GitSwarm to keep checking for updates?"
  ## when no update is available, if I navigate to the homepage I should see a banner that says "You are running the latest version of GitSwarm (2015.1). Allow GitSwarm to keep checking for updates?"
  ## when no update is available but the latest version is marked as critical, if I navigate to the homepage I should see a banner that says "You are running the latest version of GitSwarm (2015.1). Allow GitSwarm to keep checking for updates?"
  ## when my release is ahead of the current available release, if I navigate to the homepage I should see a banner with "You are running the latest version of GitSwarm (2015.1). Allow GitSwarm to keep checking for updates?" ?? Odd scenario for anyone other than us but technically that banner is wrong.
  ## when the available release version does not conform to the correct format "Major.Minor-Build" (for example, a blank string), if I navigate to the homepage I should see a banner that says "You are running the latest version of GitSwarm (2015.1). Allow GitSwarm to keep checking for updates?"
  ## with a banner notification on the homepage, when I close the banner by clicking the X, verify that the session cookie dismiss_version_check is set and the banner does not appear for the remainder of the browser session
  ## with a banner notification on the homepage, reply yes and verify that the user is taken to the admin settings and the checkbox is checked. Confirm in the database that the admin has version_check_enabled set to t
  ## with a banner notification on the homepage, reply no and verify that the user is taken to the admin settings and the checkbox is not checked. Confirm in the database that the admin has version_check_enabled set to f

  # As a regular user verify that the banner notifications do not appear.

## Additional Test cases ###

  ## Setting an invalid a '.platform' value ( which does not hit any existing architecture), and then running tests with & without no-arch 
  ## The updates are set to be true, and no-arch is ahead of existing version
  ## Updates should be seen on dashboard WITH 'no-arch' model ( as they would with any other model)
  ## No updates should be see on dashboard WITHOUT the 'no-arch' json section. In that case, all updates will be disabled
  ## Missing ".platform" file - verify what happens . Correctly reverts to a 'no-arch' model.
  ## multiple admins created -> all see the same settings for version check
  ## On a GitSwarm version upgrade -> the existing visibility settings in the database should be maintained when GitSwarm is upgarded to a later version. 
  ## For example, if the visibility flag is set to OFF, then it should continue to remain OFF and vice-versa
  ## The version check enabled flag DOES get toggled if we check/uncheck the flag on 'application settings page'
  ## Tested with the "more_info" flag. Verified that we see the growl message "This Installation of GitSwarm is out of date. An update is available.", where the 'update is available' 
  ## flag message gets linked to the 'more_info' http page
  ## Verified that release that the user's first version is 'MAJOR.MINOR-BUILD' and not just 'MAJOR.MINOR' , with BUILD_value = 0. This takes care of PGL-811
  ## Verified that when production JSON page 'updates.perforce.com/static/GitSwarm/GitSwarm.json' is used for testing, the stats do flow to the graphs on the page 'http://gather-dev.perforce.com/'
  
  ## Note: For a given platform, the patch versions need not be linear, and can have hops
  ## For example, lets say for a release 2015-1, we start at patch 1 for all OSes ( i.e. 2015.1-1)
  ## Then we push a patch '2' to ubuntu, making ubuntu build revisions at  2015-1-2
  ## We now push a patch '3' to centos, making centos build revision at  2015-1-3
  ## Now when we want to push to ubuntu again, the person will receive an update from '2015.1-2' to '2015.1-4'

  