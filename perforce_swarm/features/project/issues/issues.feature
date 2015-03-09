@issues
Feature: Project Issues
  Background:
    Given I sign in as a user
    And I own project "PerforceProject"
    And project "PerforceProject" has "Tumblr control" open issue
    And project "PerforceProject" has "HipChat" open issue
    And I visit project "PerforceProject" issues page

  #########################
  # New Issue Page - Title
  #########################

  Scenario: A title with special characters on the New Issue page
    Given I click link "New Issue"
    And I submit new issue "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"
    Then I should see issue "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"

  Scenario: A blank title on the New Issue page
    Given I click link "New Issue"
    And I submit new issue without a title
    Then I should see the error message "Title can't be blank"

  #########################
  # New Issue Page - Description
  #########################

  Scenario: Using special characters in the description field on the New Issue page
    Given I click link "New Issue"
    And I submit new issue with the description "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"
    Then I should see an issue with the description "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"

  Scenario:  Using a valid @mention user in the description field on the New Issue page
    Given I click link "New Issue"
    And user "John" exists
    When I submit new issue with "@John" in the description field
    Then I should see an issue with a link to John's profile page in the description

  Scenario:  Using an invalid @mention user in the description field on the New Issue page
    Given I click link "New Issue"
    And I submit new issue with an invalid @mention user in the description field
    Then I should see an issue that does not have a link to the invalid @mention user

  Scenario: Using #1 in the description field on the New Issue page
    Given I click link "New Issue"
    And I submit new issue with a #1 in the description field
    Then I should see an issue with an issue link in the description

  Scenario: Using #12345 that does not refer to an issue in the description field on the New Issue page
    Given I click link "New Issue"
    And I submit new issue with a #12345 in the description field
    Then I should see an issue that does not have an issue link in the description

  Scenario: Using !1 that refers to an existing merge request in the description field on the New Issue page
    Given I click link "New Issue"
    And merge request #1 exists
    And I submit new issue with a !1 in the description field
    Then I should see an issue with a merge request link in the description

  Scenario: Using !12345 that does not refer to a merge request in the description field on the New Issue page
    Given I click link "New Issue"
    And I submit new issue with a !12345 in the description field
    Then I should see an issue that does not have a merge request link in the description

  Scenario: Using $1 that refers to an existing code snippet in the description field on the New Issue page
    Given I click link "New Issue"
    And code snippet #1 exists
    When I submit new issue with a $1 in the description field
    Then I should see an issue with a snippet link in the description

  Scenario: Using $12345 that does not refer to a code snippet in the description field on the New Issue page
    Given I click link "New Issue"
    And I submit new issue with a $12345 in the description field
    Then I should see an issue that does not have a snippet link in the description

  Scenario: Using first 7 characters of a valid commit in the description field on the New Issue page
    Given I click link "New Issue"
    And commit "5984d3d1" exists
    When I submit new issue with "5984d3d1" in the description field
    Then I should see an issue with a commit link to "5984d3d1" in the description

  #########################
  # New Issue Page - Attaching image or file
  #########################

  Scenario: Attach a jpg image to an issue from the "selecting them" link on the New Issue page
    Given I click link "New Issue"
    And I click on "selecting them" link
    And upload a jpg image
    Then I should see an issue with an image uploaded

  Scenario: Attach a png image to an issue from the "selecting them" link on the New Issue page
    Given I click link "New Issue"
    And I click on "selecting them" link
    And upload a png image
    Then I should see an issue with an image uploaded

  Scenario: Attach a gif image to an issue from the "selecting them" link on the New Issue page
    Given I click link "New Issue"
    And I click on "selecting them" link
    And upload a gif image
    Then I should see an issue with an image uploaded

  Scenario: Attach a jpg image to an issue by dragging and dropping on the New Issue page
    Given I click link "New Issue"
    And I drag and drop a gif image
    Then I should see an issue with an image uploaded

  Scenario: Attach a png image to an issue by dragging and dropping on the New Issue page
    Given I click link "New Issue"
    And I drag and drop a png image
    Then I should see an issue with an image uploaded

  Scenario: Attach a gif image to an issue by dragging and dropping on the New Issue page
    Given I click link "New Issue"
    And I drag and drop a gif image
    Then I should see an issue with an image uploaded

  Scenario: Attach a file other than jpg, png, or gif to an issue by dragging and dropping on the New Issue page
    Given I click link "New Issue"
    And I drag and drop the file
    Then I should see the error message, "You can't upload files of this type."

  Scenario: Attach a file that is larger than 10MB.
    Given I click link "New Issue"
    And I drag and drop a file larger than 10MB.
    Then I should see the error message, "File is too big.  Max filesize:  10MiB"

  #########################
  # New Issue Page - Markdown
  #########################

  Scenario: A description with a url
    Given I click link "New Issue"
    And I submit new issue with a url
    Then I should see an issue with a url link in the description

  Scenario: A description with bold and italicized markdown
    Given I click link "New Issue"
    And I submit new issue with bold and italicized markdown
    Then I should see an issue with bold and italicized words in the description

  Scenario: A description with lists markdown
    Given I click link "New Issue"
    And I submit new issue with lists markdown
    Then I should see an issue with lists in the description

  # Scenario already written in features/project/issues/issues.feature
  Scenario: A description with headers markdown
    Given I click link "New Issue"
    And I submit new issue with headers markdown
    Then I should see an issue with headers in the description

  # Scenario already written in features/project/issues/issues.feature
  Scenario: A description with checkboxes markdown
    Given I click link "New Issue"
    And I submit new issue with checkboxes markdown
    Then I should see an issue with checkboxes in the description

  # Scenario already written in features/project/issues/issues.feature
  Scenario: A description with tasks markdown
    Given I click link "New Issue"
    And I submit new issue with tasks markdown
    Then I should see an issue with tasks in the description

  #########################
  # New Issue Page - Assignee
  #########################

  Scenario: I submit a new assigned issue
    Given I click link "New Issue"
    And I assign an issue to a user
    And I submit new issue "Issue assigned to different user"
    Then I should see issue assigned to the user

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I submit new unassigned issue
    Given I click link "New Issue"
    And I submit new issue "500 error on profile"
    Then I should see issue "500 error on profile"

  Scenario: I submit a new issue assigned to me
    Given I click link "New Issue"
    And I assign an issue to myself
    And I submit new issue "Issue assigned to myself"
    Then I should see issue assigned to me

  #########################
  # New Issue Page - Milestone
  #########################

  # Scenario already written in features/project/issues/milestones.feature
  Scenario: I submit a new issue assigned to a milestone
    Given I click link "New Issue"
    And I assign an issue to a milestone
    And I submit new issue "Issue assigned to milestone"
    Then I should see issue assigned to a milestone

  Scenario: I submit a new issue without a milestone
    Given I click link "New Issue"
    And I assign an issue without a milestone
    And I submit new issue "Issue without a milestone"
    Then I should see issue without a milestone

  #########################
  # New Issue Page - Label
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: I submit a new issue with a label
    Given I click link "New Issue"
    And I assign an issue with a label
    And I submit new issue "Issue with a label"
    Then I should see issue with a label

  Scenario: I submit a new issue without a label
    Given I click link "New Issue"
    And I assign an issue without a label
    And I submit new issue "Issue without a label"
    Then I should see issue without a label

  #########################
  # New Issue Page - Cancel
  #########################

  Scenario: I cancel an issue on the New Issue page
    Given I click link "New Issue"
    And I input a title
    And I cancel the issue
    Then an issue should not be created

  #########################
  # Edit Issue Page - Title
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: A title changed on the Edit Issue page
    Given I click on "Edit" button
    And I change the title of an issue "Changed title"
    Then I should see issue "Changed title"

  Scenario: A blank title on the Edit Issue page
    Given I click on "Edit" button
    And I change the title of an issue to blank
    Then I should see the error message "Title can't be blank"

  #########################
  # Edit Issue Page - Description
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: A description changed on the Edit Issue page
    Given I click on "Edit" button
    And I change the description of an issue "Changed description"
    Then I should see issue with description "Changed description"

  #########################
  # Edit Issue Page - Assignee
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: An assignee changed on the Edit Issue page
    Given I click on "Edit" button
    And I change the assignee of an issue
    Then I should see issue assigned to the user

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: An assignee changed to unassigned on the Edit Issue page
    Given I click on "Edit" button
    And I change the assignee of an issue to unassigned
    Then I should see issue no longer assigned

  Scenario: An issue assigned to me on the Edit Issue page
    Given I click on "Edit" button
    And I click on the assigned to me button
    Then I should see issue assigned to me

  #########################
  # Edit Issue Page - Milestone
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: A milestone changed on the Edit Issue page
    Given I click on "Edit" button
    And I change the milestone of an issue
    Then I should see issue with new milestone

  Scenario: A milestone added on the Edit Issue page
    Given I click on "Edit" button
    And I add a milestone of an issue
    Then I should see issue with a milestone

  Scenario: A milestone changed to unassigned on the Edit Issue page
    Given I click on "Edit" button
    And I change the milestone of an issue to unassigned
    Then I should see issue without a milestone

  #########################
  # Edit Issue Page - Label
  #########################

  Scenario: A label added on the Edit Issue page
    Given I click on "Edit" button
    And I add a label of an issue
    Then I should see issue with label

  Scenario: A label removed on the Edit Issue page
    Given I click on "Edit" button
    And I remove a label of an issue
    Then I should see issue without the label

  #########################
  # Edit Issue Page - Cancel
  #########################

  Scenario: I cancel an issue on the Edit Issue page
    Given I click on "Edit" button
    And I cancel the issue
    Then an issue should not have changed

  #########################
  # Single Issue Page - Not the Edit Issue page
  #########################

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I visit issue page
    Given I click link "Release 0.4"
    Then I should see issue "Tumblr control"

  Scenario: An assignee changed on a single issue page
    Given I click link "Tumblr control"
    And I change the assignee of an issue
    Then I should see issue assigned to the user

  Scenario: An milestone changed on a single issue page
    Given I click link "Tumblr control"
    And I change the milestone of an issue
    Then I should see issue with new milestone

  Scenario: An milestone changed to unassigned on a single issue page
    Given I click link "Tumblr control"
    And I change the milestone of an issue to unassigned
    Then I should see issue with no milestone

  @automated @PGL-521
  Scenario: I click the "Close" button on a single issue page
    Given I visit issue page "Tumblr control"
    And I click the "Close" button
    Then I should see the issue closed
    When I visit project "PerforceProject" issues page
    Then I should not see "Tumblr control" in issues
    And I should see "HipChat" in issues

  @automated @PGL-521
  Scenario: I click the "Close Issue" button on a single issue page
    Given I visit issue page "Tumblr control"
    And I click the "Close Issue" button
    Then I should see the issue closed
    When I visit project "PerforceProject" issues page
    Then I should not see "Tumblr control" in issues
    And I should see "HipChat" in issues

  Scenario: I reopen an issue on a single issue page
    Given I visit issue page "Closed issue"
    And I reopen the issue
    Then I should see the issue reopened

  #########################
  # Single Issue Page - Not the Edit Issue page
  # Commenting
  #########################

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I comment issue
    Given I visit issue page "Tumblr control"
    And I leave a comment like "XML attached"
    Then I should see comment "XML attached"

  Scenario: I comment issue with special characters on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment like "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"
    Then I should see comment "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"

  Scenario: I comment issue with a valid @mention user on a single issue page
    Given I visit issue page "Tumblr control"
    And user "John" exists
    When I leave a comment with "@John"
    Then I should see a comment with a link to John's profile page

  Scenario: I comment issue with an invalid @mention user on a single issue page
    Given I visit issue page "Tumblr control"
    When I leave a comment with an invalid @mention user
    Then I should see a comment without a link

  Scenario: I comment issue with #1 on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment with a #1
    Then I should see a comment with an issue link

  Scenario: I comment issue with #123 that does not refer to an issue on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment with a #123
    Then I should see a comment without an issue link

  Scenario: I comment issue with !1 that refers to an existing merge request on a single issue page
    Given I visit issue page "Tumblr control"
    And merge request #1 exists
    And I leave a comment with a !1
    Then I should see a comment with a merge request link

  Scenario: I comment issue with !12345 that does not refer to a merge request on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment with a !1
    Then I should see a comment without a merge request link

  Scenario: I comment issue with $1 that refers to an existing code snippet on a single issue page
    Given I visit issue page "Tumblr control"
    And code snippet #1 exists
    And I leave a comment with a $1
    Then I should see a comment with a snippet link

  Scenario: I comment issue with $12345 that does not refer to an existing code snippet on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment with a $12345
    Then I should see a comment without a snippet link

  Scenario: I comment issue with first 7 characters of a commit on a single issue page
    Given I visit issue page "Tumblr control"
    And commit "5984d3d1" exists
    And I leave a comment with "5984d3d1" exists
    Then I should see a comment with a commit link

  Scenario: I comment issue with +1 on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment with +1
    Then I should see a comment with icon thumbs up

  Scenario: I comment issue with -1 on a single issue page
    Given I visit issue page "Tumblr control"
    And I leave a comment with -1
    Then I should see a comment with icon thumbs down

  Scenario: I edit a comment
    Given I visit issue page "Commented Issue"
    And I edit a comment with "Different Comment"
    Then I should see comment "Commented Issue"

  Scenario: I edit a comment with special characters
    Given I visit issue page "Commented Issue"
    And I edit a comment with "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"
    Then I should see comment "!@#$%^&*()_+-=[]\{}|;':",./<>?`~'"

  Scenario: I edit a comment with valid @mention user
    Given I visit issue page "Commented Issue"
    And user "John" exists
    When I edit a comment with "@John"
    Then I should see a comment with a link to John's profile page

  Scenario: I edit a comment with #1
    Given I visit issue page "Commented Issue"
    And I edit a comment with a #1
    Then I should see a comment with an issue link

  Scenario: I edit a comment with !1
    Given I visit issue page "Commented Issue"
    And merge request #1 exists
    When I edit a comment with a !1
    Then I should see a comment with a merge request link

  Scenario: I edit a comment with $1
    Given I visit issue page "Commented Issue"
    And code snippet #1 exists
    When I edit a comment with a $1
    Then I should see a comment with a snippet link

  Scenario: I edit a comment with the first 7 characters of a commit
    Given I visit issue page "Commented Issue"
    And commit "5984d3d1" exists
    When I edit a comment with "5984d3d1"
    Then I should see a comment with a commit link

  Scenario: I edit a comment with +1
    Given I visit issue page "Commented Issue"
    And I edit a comment with +1
    Then I should see a comment with icon thumbs up

  Scenario: I edit a comment with -1
    Given I visit issue page "Commented Issue"
    And I edit a comment with -1
    Then I should see a comment with icon thumbs down

  Scenario: I remove a comment
    Given I visit issue page "Commented Issue"
    And I remove a comment
    Then I should not see a comment in the issue

  #########################
  # Single Issue Page - Not the Edit Issue page
  # Attaching or downloading image or file
  #########################

  Scenario: I "Choose File" txt on a single issue page
    Given I visit issue page "Tumblr control"
    And I choose file txt
    Then I should see txt file uploaded

  Scenario: I "Choose File" docx on a single issue page
    Given I visit issue page "Tumblr control"
    And I choose file docx
    Then I should see docx file uploaded

  Scenario: I "Choose File" zip on a single issue page
    Given I visit issue page "Tumblr control"
    And I choose file zip
    Then I should see zip file uploaded

  Scenario: I download file on a single issue page
    Given I visit issue page "Uploaded file"
    And I download
    Then I should see file downloaded

  Scenario: Attach a jpg image to an issue from the "selecting them" link on a single issue page
    Given I visit issue page "Tumblr control"
    And I click on "selecting them" link
    And upload a jpg image
    Then I should see an issue with an image uploaded

  Scenario: Attach a png image to an issue from the "selecting them" link on a single issue page
    Given I visit issue page "Tumblr control"
    And I click on "selecting them" link
    And upload a png image
    Then I should see an issue with an image uploaded

  Scenario: Attach a gif image to an issue from the "selecting them" link on a single issue page
    Given I visit issue page "Tumblr control"
    And I click on "selecting them" link
    And upload a gif image
    Then I should see an issue with an image uploaded

  Scenario: Attach a jpg image to an issue by dragging and dropping on a single issue page
    Given I visit issue page "Tumblr control"
    And I drag and drop a gif image
    Then I should see an issue with an image uploaded

  Scenario: Attach a png image to an issue by dragging and dropping on a single issue page
    Given I visit issue page "Tumblr control"
    And I drag and drop a png image
    Then I should see an issue with an image uploaded

  Scenario: Attach a gif image to an issue by dragging and dropping on a single issue page
    Given I visit issue page "Tumblr control"
    And I drag and drop a gif image
    Then I should see an issue with an image uploaded

  Scenario: Attach a file other than jpg, png, or gif to an issue by dragging and dropping on a single issue page
    Given I visit issue page "Tumblr control"
    And I drag and drop the file
    Then I should see the error message, "You can't upload files of this type."

  Scenario: Attach a file that is larger than 10MB on a single issue page
    Given I visit issue page "Tumblr control"
    And I drag and drop a file larger than 10MB.
    Then I should see the error message, "File is too big.  Max filesize:  10MiB"

  #########################
  # Single Issue Page - Not the Edit Issue page
  # Markdown
  #########################

  # Scenario already written in features/project/issues/issues.feature
  Scenario: Blocks inside comments should not build relative links
    Given I visit issue page "Tumblr control"
    And I leave a comment with code block
    Then The code block should be unchanged

  Scenario: Use emoji markdown in a comment and preview
    Given I visit issue page "Tumblr control"
    And I add emoji in the comment and preview
    When I click on Add Comment button
    Then I should see emoji icon

  Scenario: Use emoji markdown in a comment and preview
    Given I visit issue page "Tumblr control"
    And I add emoji in the comment and preview
    When I click on Add Comment button
    Then I should see emoji icon

  Scenario: Use header markdown in a comment and preview
    Given I visit issue page "Tumblr control"
    And I add header markdown in the comment and preview
    When I click on Add Comment button
    Then I should see an issue with headers in the description

  # Scenario already written in features/project/issues/issues.feature
  Scenario: Issue notes should not render task checkboxes
    Given project "Shop" has "Tasks-open" open issue with task markdown
    When I visit issue page "Tasks-open"
    And I leave a comment with task markdown
    Then I should not see task checkboxes in the comment

  Scenario: I have nothing to preview
    Given I visit issue page "Tumblr control"
    And I click on preview tab
    Then I should see "Nothing to preview"

  #########################
  # Issues List Page - Left Hand Side (Everyone's, Assigned to me, Created by me)
  #########################

  Scenario: I should see Everyones and Created by me count increase by 1 on the issues list page
    Given I click link "New Issue"
    And I submit new issue
    And I visit project "Shop" issues page
    Then I should see Everyones count increase by 1
    And I should see Created by me count increase by 1

  Scenario: I should see Assigned to me count increase by 1 on the issues list page
    Given I click link "New Issue"
    And I assign an issue to myself
    And I submit new issue "Issue assigned to myself"
    And I visit project "Shop" issues page
    Then I should see Assigned to me count increase by 1

  Scenario: I should see Everyones and Created by me count stay the same on the issues list page
    Given I logout and login as a different user
    And I am a member of project "Shop"
    And I visit project "Shop" issues page
    When I click link "New Issue"
    And I submit new issue
    And I visit project "Shop" issues page
    Then I should see Everyones count stay the same
    And I should see Created by me count stay the same

  Scenario: Filter by "Assigned to me"
    Given I click on Assigned to me filter
    Then I should only see issues assigned to me on the issues list

  Scenario: Filter by "Created by me"
    Given I click on Created by me filter
    Then I should only see issues created by me on the issues list

  #########################
  # Issues List Page - Left Hand Side (State)
  #########################

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I should see open issues
    Given I should see "Release 0.4" in issues
    And I should not see "Release 0.3" in issues

  Scenario: I should see open issues after reopening an issue
    Given I visit issue page "Closed issue"
    And I reopen the issue
    When I visit project "Shop" issues page
    Then I should see the open issues count increase by 1

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I should see closed issues
    Given I click link "Closed" filter
    Then I should see "Release 0.3" in issues
    And I should not see "Release 0.4" in issues

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I should see all issues
    Given I click link "All"
    Then I should see "Release 0.3" in issues
    And I should see "Release 0.4" in issues

  #########################
  # Issues List Page - Left Hand Side (Labels)
  #########################

  Scenario: I should see a label after creating one on the issues list page
    Given I create a new label
    And I visit project "Shop" issues page
    Then I should see the label on the issues list page

  Scenario: I should no longer see a label after deleting one on the issues list page
    Given I delete a label
    And I visit project "Shop" issues page
    Then I should no longer see the label on the issues list page
    And issues with that label should no longer have the label

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I filter by one label
    Given I click link "bug"
    Then I should see "Bugfix1" in issues list
    And I should see "Bugfix2" in issues list
    And I should not see "Feature1" in issues list

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I filter by two labels
    Given I click link "bug"
    And I click link "feature"
    Then I should see "Bugfix1" in issues list
    And I should not see "Bugfix2" in issues list
    And I should not see "Feature1" in issues list

  Scenario: I click on the "Clear filter" link on the issues list page
    Given I click on Created by me filter
    And I click link "All"
    And I click link "bug"
    When I click on the "Clear filter" link
    Then all filters should be cleared and default issues are displayed

  #########################
  # Issues List Page - Left Hand Side (Filtering by multiple criteria)
  #########################

  Scenario: I filter by 'Assigned to me' and 'Closed'
    Given I click on Assigned to me filter
    And I click link "Closed"
    Then I should see only issues that are closed and assigned to me issues list

  Scenario: I filter by label and 'Created by me'
    Given I click on a label
    And I click on Created by me filter
    Then I should see only issues with that label and created by me in issues list

  Scenario: I filter by label and 'Everyone's'
    Given I click on a label
    And I click on Everyone's
    Then I should see only issues with that label in issues list

  #########################
  # Issues List Page - Search
  #########################

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I search issue
    Given I fill in issue search with "Re"
    Then I should see "Release 0.4" in issues
    And I should not see "Release 0.3" in issues
    And I should not see "Tweet control" in issues

  Scenario: Search issues when search string is case-insensitive and matches title
    Given I fill in issue search with "tumblr"
    Then I should see "Tumblr control" in issues
    And I should not see "HipChat" in issues

  # Scenario already written in features/project/issues/issues.feature
  Scenario: I search all issues
    Given I click link "All"
    And I fill in issue search with ".3"
    Then I should see "Release 0.3" in issues
    And I should not see "Tumblr control" in issues

  # Scenario already written in features/project/issues/issues.feature
  Scenario: Search issues when search string partially matches issue description
    Given project 'Shop' has issue 'Bugfix1' with description: 'Description for issue1'
    And project 'Shop' has issue 'Feature1' with description: 'Feature submitted for issue1'
    And I fill in issue search with 'issue1'
    Then I should see 'Feature1' in issues
    Then I should see 'Bugfix1' in issues
    And I should not see "Release 0.4" in issues
    And I should not see "Release 0.3" in issues
    And I should not see "Tweet control" in issues

  Scenario: Search issues when search string is case-insensitive and matches description
    Given I fill in issue search with "Post"
    Then I should see "Tumblr control" in issues
    And I should not see "HipChat" in issues

  Scenario: Search issues when search string does not produce any results
    Given I fill in issue search with a string that does not exist
    Then I should see no issues in the issues list

  Scenario: Search issues when search string is unicode
    Given I fill in issue search with a string is unicode
    Then I should see no issues in the issues list

  #########################
  # Issues List Page - Assignee Dropdown
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Filter issues by a single user using assignee dropdown
    Given I filter issue by a single user using assignee dropdown
    Then I should only see issues by user

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Filter issues by unassigned using assignee dropdown
    Given I filter issue by unassigned using assignee dropdown
    Then I should only see issues unassigned

  Scenario: Verify that assignee filter is url persistent
    Given I filter issue by a single user using assignee dropdown
    And I copy and paste the url
    Then the url should be persistent and not give 404

  #########################
  # Issues List Page - Milestone Dropdown
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Filter issues by milestone using milestone dropdown
    Given I filter issue by milestone using milestone dropdown
    Then I should only see issues with the milestone

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Filter issues by 'none' milestone using milestone dropdown
    Given I filter issue by 'none' milestone using milestone dropdown
    Then I should only see issues without milestones

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Filter issues by 'any' milestone using milestone dropdown
    Given I filter issue by 'any' milestone using milestone dropdown
    Then I should only see all issues with or without milestones

  Scenario: I delete a milestone and verify that issues with milestone still exist
    Given I delete a milestone
    Then I should still see issues with milestone exist

  Scenario: Verify that milestone filter is url persistent
    Given I filter issue by milestone using milestone dropdown
    And I copy and paste the url
    Then the url should be persistent and not give 404

  #########################
  # Issues List Page - Sort Dropdown
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Sort issues by 'newest' using sort dropdown
    Given I sort issues by 'newest'
    Then I should see issues sorted by newest

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Sort issues by 'oldest' using sort dropdown
    Given I sort issues by 'oldest'
    Then I should see issues sorted by oldest

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Sort issues by 'recently updated' using sort dropdown
    Given I sort issues by 'recently updated'
    Then I should see issues sorted by recently updated

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Sort issues by 'Milestone due soon' using sort dropdown
    Given I sort issues by 'Milestone due soon'
    Then I should see issues sorted by earliest milestone date

  Scenario: Change an issue to a later milestone and sort issues by 'Milestone due soon' using sort dropdown
    Given I assign an issue to a later milestone
    And I sort issues by 'Milestone due soon'
    Then I should see issues sorted by earliest milestone date

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Sort issues by 'Milestone due later' using sort dropdown
    Given I sort issues by 'Milestone due later'
    Then I should see issues sorted by later milestone date

  Scenario: Change an issue to an earlier milestone and sort issues by 'Milestone due later' using sort dropdown
    Given I assign an issue to a earlier milestone
    And I sort issues by 'Milestone due later'
    Then I should see issues sorted by later milestone date

  #########################
  # Issues List Page - Filtering by multiple dropdown criteria
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario: Filter issues by assignee dropdown and sort by 'oldest'
    Given I filter issue by a single user using assignee dropdown
    And I sort issues by 'oldest'
    Then I should only see issues by user sorted by oldest

  Scenario: Filter issues by assignee dropdown, label, and sort by 'newest'
    Given I filter issue by a single user using assignee dropdown
    And I sort issues by 'newest'
    And I click link "bug"
    Then I should only see issues by user sorted by newest with the label

  #########################
  # Issues List Page - Checkbox
  #########################

  Scenario:  I click 'all' checkbox and update issues to closed
    Given I click on the 'all' checkbox
    And I change the status to closed
    Then I should see all issues closed in the issues list

  Scenario:  I click 'all' checkbox and update issues to opened
    Given I click on the 'all' checkbox
    And I change the status to opened
    Then I should see all issues opened in the issues list

  Scenario:  I click 'all' checkbox and update issues to assignee
    Given I click on the 'all' checkbox
    And I change the assignee in the assignee dropdown
    Then I should see all issues assigned to assignee in the issues list

  Scenario:  I click 'all' checkbox and update issues to milestone
    Given I click on the 'all' checkbox
    And I change the milestone in the milestone dropdown
    Then I should see all issues assigned to milestone in the issues list

  Scenario:  I click a single checkbox and update issues to closed
    Given I click on a single checkbox
    And I change the status to closed
    Then I should see the issue closed in the issues list

  Scenario:  I click a single checkbox and update issues to opened
    Given I click on a single checkbox
    And I change the status to opened
    Then I should see the issue opened in the issues list

  Scenario:  I click a single checkbox and update issues to assignee
    Given I click on a single checkbox
    And I change the assignee in the assignee dropdown
    Then I should see the issue assigned to assignee in the issues list

  Scenario:  I click a single checkbox and update issues to milestone
    Given I click on a single checkbox
    And I change the milestone in the milestone dropdown
    Then I should see the issue assigned to milestone in the issues list

  Scenario:  I click on multiple checkboxes and update issues to closed
    Given I click on multiple checkboxes
    And I change the status to closed
    Then I should see the multiple issues closed in the issues list

  Scenario:  I click on multiple checkboxes and update issues to opened
    Given I click on multiple checkboxes
    And I change the status to opened
    Then I should see the multiple issues opened in the issues list

  Scenario:  I click on multiple checkboxes and update issues to assignee
    Given I click on multiple checkboxes
    And I change the assignee in the assignee dropdown
    Then I should see the multiple issues assigned to assignee in the issues list

  Scenario:  I click on multiple checkboxes and update issues to milestone
    Given I click on multiple checkboxes
    And I change the milestone in the milestone dropdown
    Then I should see the multiple issues assigned to milestone in the issues list

  #########################
  # Issues List Page - Edit and Close
  #########################

  Scenario:  I close an issue with the close button in the issues list
    Given I close an issue with the close button in the issues list
    Then the issue should no longer appear in the issues list

  Scenario:  I edit an issue with the edit button in the issues list
    Given I edit an issue with the edit button in the issues list
    Then I should be taken to the Edit Issue page

  #########################
  # Issues List Page - Clicking on issue
  #########################

  Scenario: Clicking on issue link of an issue titled !1
    Given I click link "New Issue"
    And I submit new issue with a !1 in the description field
    And I visit project "PerforceProject" issues page
    When I click on issue link of issue titled !1
    Then I should see issue page and not merge request page

  Scenario: Clicking on issue link of an issue titled with first 7 characters of a commit
    Given I click link "New Issue"
    And I submit new issue with the first 7 characters of a commit in the description field
    And I visit project "PerforceProject" issues page
    When I click on issue link of issue titled !1
    Then I should see issue page and not commit page

  #########################
  # User-Related
  #########################

  # Rspec test already written for this scenario in: spec/features/issues_spec.rb
  Scenario:  As a guest user, I navigate to a single issue page
    Given I logout and go to a single issue page
    Then I should not be able to change the assignee and milestone field

  @PGL-428 # Scenario currently does not work as described.  See PGL-428
  Scenario:  Delete a user and verify that issues still appear in the project
    Given I logout and login as an admin
    And I delete a user from Project "Shop"
    Then all issues from the user should be "unassigned" and not be deleted

  Scenario:  Block a user and verify that issues still appear in the project
    Given I logout and login as an admin
    And I block a user from Project "Shop"
    Then all issues from the user should still appear and not be deleted

  #########################
  # Closing Issues Automatically
  #########################

  Scenario:  Close an issue in a merge request description
    Given I create an issue "IssueToClose"
    And I create a merge request with "close #1"
    When I accept the merge request
    Then "IssueToClose" should be closed

  Scenario:  Close an issue using a commit
    Given I create an issue "IssueToClose"
    And I push a commit with a message "close #1"
    Then "IssueToClose" should be closed

  #########################
  # Permissions-Related
  #########################

  Scenario:  As a non-authenticated user on a public/internal project, verify that user cannot close or edit an issue
    Given I am logged out
    And I visit the issues list page of a project
    When I click on an issue
    Then there should be no "Close" or "Edit" button on the issue page

  Scenario:  As a non-authenticated user on a public/internal project, verify that user cannot create an issue
    Given I am logged out
    And I visit the issues list page of a project
    Then there should be no "New issue" button on the issues list pages
    When I click on an issue
    Then there should be no "New issue" button on the issue page

  Scenario:  As a non-authenticated user on a public/internal project, verify that user can visit the issues list page
    Given I am logged out
    And I visit the issues list page of a project
    Then I should see the issues list page

  Scenario:  As a non-authenticated user on a private project, verify that user cannot visit the issues list page
    Given I am logged out
    And I visit the issues list page of a private project
    Then I should see the issues list page

  Scenario:  As guest user on a public/internal/private project, verify that user can visit the issues list page
    Given I am a guest on a project
    And I visit the issues list page of a project
    Then I should see the issues list page

  Scenario:  As guest user on a public/internal/private project, verify that user can create an issue and edit your own issue
    Given I am a guest on a project
    And I visit the issues list page of a project
    Then I should create "New issue" button on the issues list pages
    And I should be able to update the issue

  Scenario:  As guest user on a public/internal/private project, verify that user cannot edit other member's issues
    Given I am a guest on a project
    And I visit the issues list page of a project
    When I click on an issue
    Then there should be no "Close" or "Edit" button on the issue page

  Scenario:  As reporter user on a public/internal/private project, verify that user cannot edit other member's issues
    Given I am a reporter on a project
    And I visit the issues list page of a project
    When I click on an issue
    Then there should be no "Close" or "Edit" button on the issue page

  Scenario:  As developer user on a public/internal/private project, verify that user can edit other member's issues
    Given I am a developer on a project
    And I visit the issues list page of a project
    When I click on an issue
    Then there should be "Close" or "Edit" button on the issue page

  #########################
  # Back Button Behavior
  #########################

  Scenario: I click the back button after creating an issue on the New Issue page
    Given I click link "New Issue"
    And I submit new issue
    And I click the back button
    Then I should see the new issue page
    When I submit new issue
    Then a different issue should be created

  Scenario: I click the back button twice after creating an issue on the New Issue page
    Given I click link "New Issue"
    And I submit new issue
    And I click the back button
    And I click the back button again
    Then I should see the issues list page

  Scenario: I click the back button after editing the description of an issue on the Edit Issue page
    Given I click on "Edit" button
    And I change the description of an issue "Different Description"
    And I submit updated issue
    And I click the back button
    Then I should see issue with "Different Description"

  Scenario: I click the back button after searching for an issue
    Given I go to the issues list page
    And I do a search for an issue
    When I click on the issue
    And I click the back button
    Then I should be on the issues list page
