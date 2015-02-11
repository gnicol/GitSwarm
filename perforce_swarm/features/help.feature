@help
Feature: Help

  #########################
  # Help
  #########################

  Scenario: Click on the help button and verify that user is directed to the help page.
    Given ...

  Scenario: Click on the "Install" link and then the "Installation" link and verify that user is taken to the Installation page.
    Given ...
    # Verify that Installation procedure references Perforce features.

  Scenario: Click on the "Markdown" link and verify that user is taken to the Markdown page.
    Given ...

  # Any other important pages on the help page worth clicking through and testing?

  #########################
  # Search
  #########################

  Scenario: Enter a project in the search bar, and verify that results return as expected.
  # Automated in features/search.feature; Scenario: I should see project I am looking for
    Given ...

  Scenario: Navigate to a specific project dashboard, and search for a file in the project.  Verify that results return as expected.
  # Automated in features/project/source/search_code.feature; Scenario: Search for term "coffee" and
  # automated in features/search.feature; Scenario: I should see project code I am looking for
    Given ...

  Scenario: Navigate to a specific project dashboard, and search for an issue in the project.  Verify that results return as expected.
  # Automated in features/search.feature; Scenario: I should see project issues
    Given ...

  #########################
  # Manual Testing - Check help links (Community issues files in https://gitlab.com/gitlab-org/gitlab-ce/issues/1064)
  # Use an automated link checker tool.  I used wget, due to authentication issues.
  # Reference:  http://stackoverflow.com/questions/6924582/how-to-call-a-form-based-authentication-from-curl-or-wget
  #########################
