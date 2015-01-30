require Rails.root.join('features', 'steps', 'project', 'merge_requests')

class Spinach::Features::ProjectMergeRequests < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedProject

  step 'I should see last push widget' do
    page.should have_content 'You pushed to fix'
    page.should have_link 'Create Merge Request'
  end

  step 'I click "Create Merge Request" link' do
    click_link 'Create Merge Request'
  end

  step 'I see prefilled new Merge Request page' do
    current_path.should == new_project_merge_request_path(@project)
    find('#merge_request_target_project_id').value.should eq @project.id.to_s
    find('#merge_request_source_branch').value.should eq 'fix'
    find('#merge_request_target_branch').value.should eq 'master'
  end

  step 'I click button "Assign to me"' do
    click_link 'Assign to me'
  end

  step 'I submit new merge request "Jira Integration"' do
    fill_in 'merge_request_title', with: 'Jira Integration'
    click_button 'Submit merge request'
  end

  step 'I should see "Jira Integration" in merge requests' do
    page.should have_content 'Jira Integration'
  end
end
