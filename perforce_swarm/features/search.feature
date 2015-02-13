@search
Feature: Search

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
  # Help Topics in Search
  #########################

  Scenario: In the search bar, type "help: " and verify that a dropdown of help topics are displayed.
    Given ...

  Scenario: In the search bar, type "help: permissions", click on the "help: Permissions Help" dropdown, and verify that user is taken to "Permissions" page.
    Given ...
