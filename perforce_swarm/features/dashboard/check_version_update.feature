@dashboard
Feature: Check for updates feature which notifies the GitSwarm admin if the installed omnibus version is critically/non-critically out of date
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

  Scenario: Check for updates feature with different platforms on the client GitSwarm server
    # If the GitSwarm server is installed on one of the supported platforms 'centos6/centos7/ubuntu12/unbuntu14', 
    # then the admin user will receive a 'Check for update' notification ( provided other conditions are met )
    # If the GitSwarm server is installed on an unsupported OS platform ( e.g. MacOSX), then the platform state will be set as 'unknown', 
    # and the admin will never receive a 'Check for update' notification
    # The 'noarch' platform state has no logic currently associated with it. It is primarily used to imply a 'generic platform' across all GitSwarm servers
    Given ...

  Scenario: A daily sidetiq task on the server handles the 'check for version update' logic. Verify that the sidetiq task works correctly based on its its set interval
    Given ...

  Scenario: Ensure that the version check logic works correctly with the major and minor numbered ( and alpha/beta ) releases.
    # This is a high risk logic for the feature
    # The following version-update verifications are good candidates for unit testing ( similar to Gitlab's spec/lib/gitlab/version_info_spec.rb spec file )
    # a) Minor  revision checks: 2015-1-alpha < 2015-1-beta < 2015-1 ( or 2015-1-0 ) < 2015-1-1 <  2015-1-2 <  2015-2-1 < 2015-3-1
    # b) Major revision checks:  2014-4-8 < 2015-1-alpha < 2015-1-1 < 2016-1
    # Note: Ideally, we would always look at having updates from a current alpha/beta release to the next numbered release, 
    # but not necessarily from a current numbered release to its succeeding beta release
    Given ...

  ######################
  # Basic work-flow tests
  ######################

  Scenario: An admin will ALWAYS receive update version notifications if the growl "Allow Gitswarm to keep checking for updates" is accepted or if the 'version check enabled' checkbox on the admin application settings page is enabled
  # 1. The 'version check enabled' checkbox  can be set on the admin application page only ( no config file)
  # 2. By default it should be unchecked (checks turned OFF)
  # 3. The default value 'OFF' is an override of the corresponding Gitlab-CE feature. The Gitlab-CE feature for release 7.11, had version check enabled by default
    Given ...

  Scenario: Only the GitSwarm admin user will receive update 'growl notification' for out of date revisions. The notifications will be displayed on the admin dashboard page, post authentication.
    # Questions: What if the admin is not a redirected to the dashboard page - will he see the growl notifications then?
    Given ...

  Scenario: Admin will receive critical update if updates are turned ON and  MAJOR REVISION is out of date or if a critical patch is pushed by the Perforce team for a particular build version & platform
   # The updates are verified against a JSON received from https://updates.perforce.com/static/GitSwarm/GitSwarm.json, which contains information on the latest released builds for the respective platforms
   # For example, if the Gitswarm server has a build version of 2014 and the latest
    Given ...

  Scenario: Admin will receive non-critical update if updates are turned ON and MINOR REVISION or BUILD NUMBER is out of date
    Given ...


  #########################
  # Front-end verifications
  #########################

  Scenario: The growl notification should be displayed if a new admin-user signs in for the first time on a newly installed GitSwarm server, after the version check feature is enabled
    Given...

  Scenario: The update revision feature should work if an existing admin-user signs in for the first time on an existing GitSwarm server, after the version check feature is enabled
    Given...