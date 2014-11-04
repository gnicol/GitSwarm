Feature: NavBar
  Background:
    Given I sign in as a user

  @automated
  Scenario: I should see project "Shop" in my recent project dropdown
    Given I own project "Shop"
      And I visit dashboard page
    When I open the recent projects dropdown
    Then I should see "Shop" in the recent projects dropdown

  @automated
  Scenario: I should see my 5 most recent projects in my recent project dropdown
    Given I own project "Shop"
      And I own project "Forum"
      And I own an empty project
      And I own a bare project
      And I own a bare project
      And I own a bare project
      And I visit dashboard page
    When I open the recent projects dropdown
    Then I should not see "Shop" in the recent projects dropdown
      And I should see "Forum" in the recent projects dropdown
      And I should see "Empty Project" in the recent projects dropdown

