@project_commits
Feature: Project Commits Diff Comments
  Background:
    Given I sign in as a user
    And I own project "Shop"
    And I visit project commit page

  @javascript @skip-parent
  Scenario: I can add a comment on a side-by-side commit diff (right side)
    Given I open a diff comment form
    And I click side-by-side diff button
    When I leave a diff comment in a parallel view on the right side like "New comment"
    Then I should see a diff comment on the right side saying "New comment"
