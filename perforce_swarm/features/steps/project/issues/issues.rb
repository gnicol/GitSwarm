require Rails.root.join('features', 'steps', 'project', 'issues', 'issues')

class Spinach::Features::ProjectIssues < Spinach::FeatureSteps
  step 'issue "Tumblr control" is assigned to me' do
    issue_tumblr_control = Issue.find_by(title: 'Tumblr control')
    issue_tumblr_control.assignee_id = @user.id
    issue_tumblr_control.save
  end

  step 'I click "Assigned to me"' do
    click_link 'Assigned to me'
  end

  step 'I click the "Close" button' do
    page.within '.detail-page-header' do
      click_link 'Close'
    end
  end

  step 'I click the "Close Issue" button' do
    page.within first('.note-form-actions') do
      click_link 'Close Issue'
    end
  end

  step 'I should see "HipChat" in issues' do
    page.should have_content 'HipChat'
  end

  step 'I should not see "HipChat" in issues' do
    page.should_not have_content 'HipChat'
  end

  step 'I should see "Tumblr control" in issues' do
    page.should have_content 'Tumblr control'
  end

  step 'I should not see "Tumblr control" in issues' do
    page.should_not have_content 'Tumblr control'
  end

  step 'I should see the issue closed' do
    page.should have_selector('.status-box-closed')
  end

  step 'I click link "All"' do
    page.within '.content-wrapper' do
      click_link 'All'
    end
  end
end
