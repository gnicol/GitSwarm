Feature: Project Snippets
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And project "Shop" have "Snippet one" snippet
    And project "Shop" have no "Snippet two" snippet
    And I visit project "Shop" snippets page

  @skip-parent
  Scenario: I update "Snippet one"
    Given I visit snippet page "Snippet one"
    And I click link "Edit"
    And I submit new title "Snippet new title"
    Then I should see "Snippet new title"

  @skip-parent
  Scenario: I destroy "Snippet one"
    Given I visit snippet page "Snippet one"
    And I click link "Delete"
    Then I should not see "Snippet one" in snippets
