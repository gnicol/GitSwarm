@project
Feature: Git Fusion Import

  #############################
  # Disabled/invalid configuration tests
  #############################

  @automated
  Scenario: Having Git Fusion disabled results in a disabled message and no repo select drop-down on the new project page.
    Given I sign in as a user
    And Git Fusion support is disabled
    When I visit new project page
    Then I should see a Git Fusion is disabled message
    And I should not see a Git Fusion repo dropdown

  @automated
  Scenario: Having a missing Git Fusion config results in a disabled message and no repo select drop-down on the new project page.
    Given I sign in as a user
    And The Git Fusion config block is missing
    When I visit new project page
    Then I should see a Git Fusion is disabled message
    And I should not see a Git Fusion repo dropdown

  @automated
  Scenario: Having a config with an invalid URL results in a disabled message and no repo select drop-down on the new project page.
    Given I sign in as a user
    And The Git Fusion config block has a malformed URL
    When I visit new project page
    Then I should see a Git Fusion is disabled message
    And I should not see a Git Fusion repo dropdown

  @automated
  Scenario: With Git Fusion enabled, but otherwise having no config results in a disabled message and no repo select drop-down on the new project page.
    Given I sign in as a user
    And Git Fusion is enabled but is otherwise not configured
    When I visit new project page
    Then I should see a Git Fusion is disabled message
    And I should not see a Git Fusion repo dropdown

  #############################
  # Basic tests with repo listings
  #############################
  @automated
  Scenario: With Git Fusion returning an empty list of managed repos, results in a configured but no repos available message and no repo select drop-down on the new project page.
    Given I sign in as a user
    And Git Fusion returns an empty list of managed repos
    When I visit new project page
    Then I should see a message saying Git Fusion has no repos available for import
    And I should not see a Git Fusion repo dropdown

  @automated
  Scenario: With Git Fusion returning a list of repos, results in a select box filled with the same repo names.
    Given I sign in as a user
    And Git Fusion returns a list containing repos
    When I visit new project page
    Then I should see a populated Git Fusion repo dropdown

  #############################
  # Import valid GitFusion repo
  #############################

  Scenario: Create a new project by importing a valid GitFusion repo and pushing a change through GitSwarm.  Verify that change was made on p4d and GitSwarm side.
    Given ...

  # Tested (4d0cb1f)
  Scenario: Attempt to import a valid GitFusion repo with a project name that already exists.  Verify that "Name has already been taken" message appears.
    Given ...

  # Tested (4d0cb1f)
  Scenario: Attempt to import a large valid GitFusion repo that takes more than 4 minutes to import.  Verify that message regarding big repositories displays.
    Given ...

  Scenario: Attempt to import a GitFusion repo using "Any repo by URL" feature and verify that mirroring is NOT enabled for the newly-created repo.
    Given ...

  ######################################################################
  # Configuration file - Editing gitswarm.rb and then doing reconfigure
  ######################################################################

  Scenario: Verify that the master flag for git_fusion stanza in gitswarm.rb "enabled = true/false" works correctly in turning mirroring ON or OFF. By default it is set to OFF
    Given ...

  Scenario: Use a http GitFusion url to import a repo and verify that repo can be imported.
    Given ...

  Scenario: Use a https GitFusion url to import a repo and verify that repo can be imported.
    Given ...

  Scenario: Use a ssh GitFusion url to import a repo and verify that repo can be imported.
    Given ...

  # PGL-885
  Scenario: Use an invalid GitFusion url to import a repo and verify that correct messaging appears.
    Given ...

  # Tested (4d0cb1f)
  Scenario: Use "tabs" in the configuration file (rather than spaces) in between field and value of the git_fusion section
    Given ...

  # Tested (4d0cb1f)
  Scenario: Use resolvable hostname in the url.  Verify that repo list names appear in GitSwarm.
    Given ...

  Scenario: Verify that if there is an INCORRECT configuration set in the gitswarm.rb file in a particular config block, repos for that config block do not show up but rest do
    # Geoff mentioned that the application will be defensive if there is an incorrect config block, and would behave as if no config was set
    Given ...

  Scenario: Set up a MULTIPLE GF config blocks in the gitswarm.rb file pointing to multiple GF server instances, where GF servers are on DIFFERENT IP addresses, and verify corresponding repos for each server get listed
    Given ...

  Scenario: Set up a MULTIPLE GF config blocks in the gitswarm.rb file pointing to multiple GF server instances, where GF servers are on SAME IP addresses, and verify corresponding repos for each server get listed
    Given ...

   # Using an incorrect password in the gitswarm.rb file when importing with http & https
   # Setting the git_config_params: "http.sslVerify=false" flag and trying to import with ssh, http & https. Verify that ssh & http work, https should not
   # Without the git_config_params: "http.sslVerify" flag and trying to import with ssh, http & https. Verify that ssh & https work, http should not
   # In the gitswarm.rb config file, duplicate the git_fusion key, e.g. duplicate "default". What should happen is that the 2nd config stanza should win and application should read from that config
   # Veriy that multiple Git config values can be passed to the "git_config_params" flag, which would then be used by the GF Git user that handles mirroring.
   # An error when defining the "git_config_params" array would only result in mirroring being errored out; the GitSwarm application should still work as expected

  #############################
  # GitFusion url without repos
  #############################

  # Tested (4d0cb1f)
  Scenario: Configure with a GitFusion server with no repos and verify that "no repos available for import" shows
    Given ...

  # Tested (4d0cb1f)
  Scenario: Configure with a GitFusion server with no repos, then add a GitFusion repo in GitFusion, and verify that GitSwarm displays new repo to import.
    Given ...

  ##############
  # UI - related
  ##############

  Scenario: Import a GitFusion repo and logout/login with a different user.  Verify that the repo doesn't show in the list of repos to import.
    Given ...

  Scenario: Import a GitFusion repo and push changes to new repo.  Delete the repo in GitSwarm, and verify that the GitFusion repo can be imported again.
    Given ...

  # What happens if a single GF server contains multiple repos. Would the UI still look presentable
  # Make sure the documentation around "see directions link" is properly there
  # make sure that user cannot simulatenuously specify an import from GitFusion along with a generic import URL ( or an import from GitHub etc)
  # What will happen on the UI if we have multiple GF server configurations set in the gitswarm.rb config file? For this release, only the first config block shows up ,whatever it be

  #################
  # Systems Testing
  #################

  Scenario: Import a GitFusion repo and push changes to new repo.  Take down GitFusion.  What happens?
    Given ...

  Scenario: Import a GitFusion repo and push changes to new repo.  Take down p4d server.  What happens?
    Given ...

  # Verify that the sidetiq task PerforceSwarm::MirrorFetchWorker does its fetching every 5 mins such that any change to an existing repo is correctly fetched

  ##############
  # Misc
  ##############

  # verify that when the mirroring pipeline fails, a user can still pull from mirrored & non-mirrored GitSwarm projects
  # Verify that when the mirroring fails, a user can push to non-mirrored GitSwarm repos, but would get an error when pushing to any mirrored GitSwarm repo that
  # is mirrored with the failing GF server
  # What happens if a repo is mirrored into GitFusion, changes are made, and then the admin changes the gitswarm.rb file to change to a different GitFusion repo?
  # What happens if you clone or push into "old" GitSwarm repo that was connected to the "old" GitFusion?
  # What happens if repo w/mirroring is renamed in GitSwarm?  Will user still see the repo in the list of GitFusion repos?
  # Verify that any new databases migrations around imported GF repos do not potentially have any impact on the existing system behavior
  # Verify that repo names with unicode/special chars in GitFusion or P4D, do show up in the GitSwarm repo list

  ################################################################################################################################
  # Notes/Other Considerations
  #   These are other notes and considerations to take into account into testing.
  ################################################################################################################################

  # Concurrency:
  # Multiple users using different repos pointed to same GitFusion server pointed to same depot locations.
    # Perform and accept merge requests
    # Create different branches in each repo.  Verify that branches stay with its own repo.

  # Data Translations:
    # Worried about how data is translated/moved from Perforce to GitFusion to ESPECIALLY GitSwarm
    # How will repo names be handled across the different proucts?

  # Permissions-related.  Need to investigate:
    # Repos with users that have both push/pull permissions (Verity that user can push)
    # Repos with users that only have pull permissions (Verify that user can't push)
    # Repos with users that do not have permissions (Shouldn't be on the dropdown of repos.  Shouldn't be on the list)

######################
# Questions to ask DEV
######################

  # Will we have documentation on how to turn off mirroring in GitSwarm.  In the case when GF fails, as we have experienced in gfprod, is there some way admin can turn off mirroring?
  # Double-checking if we are supporting http(s) GitFusion servers.
  # Edge case scenarios that Tony emailed about.
    # 1.  What happens if you configure an ‘old’ GitFusion server, import a repo, and then make changes to the project.  Then you change the config file to point to a different/new GitFusion server.  What happens (what should happen) to the old/initial project?  Since you are no longer pointing to the old GitFusion server, I can’t imagine you can push into it, of course, however, on the “GitSwarm side” - I’m imagining user can push changes into GitSwarm, making the repo still “available.”
    # 2.  What happens if you import a GitFusion repo and create a new project, and then rename the project.  I imagine the mirrored remote stays intact, but then will the GitFusion repo list show the old GitFusion repo name (that was previously imported)?  Don’t know how the code/logic checks for that.
    # 3.  What happens if a user successfully imports a GitFusion repo and creates a new project, but then deletes the project.  I’m thinking that the user can “re-import” the same GitFusion repo and it should appear in “the list” again.