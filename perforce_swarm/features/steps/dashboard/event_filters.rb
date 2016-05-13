require Rails.root.join('features', 'steps', 'dashboard', 'event_filters')

class Spinach::Features::EventFilters < Spinach::FeatureSteps
  step 'this merge request has a comment' do
    visit merge_requests_dashboard_path

    merge_request = MergeRequest.last
    click_link merge_request.title

    # Fill in the comment form
    page.within('.js-main-target-form') do
      fill_in 'note[note]', with: 'Excellent merge'
    end

    # Submit the comment
    page.within('.js-main-target-form') do
      click_button 'Comment'
    end
  end

  step 'I should see comment event' do
    page.find('.content_list').assert_text('Excellent merge')
  end
end
