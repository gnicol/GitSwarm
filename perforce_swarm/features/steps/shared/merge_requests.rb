module SharedMergeRequests
  include Spinach::DSL

  step 'I click link "New Merge Request"' do
    click_link 'New Merge Request'
  end

  step 'I submit new merge request "PerforceProject Merge Request"' do
    select 'feature', from: 'merge_request_source_branch'
    select 'master', from: 'merge_request_target_branch'
    click_button 'Compare branches'
    fill_in 'merge_request_title', with: 'PerforceProject Merge Request'
    click_button 'Submit new merge request'
  end

  step 'I should see merge request "PerforceProject Merge Request"' do
    within '.merge-request' do
      page.should have_content 'PerforceProject Merge Request'
    end
  end
end
