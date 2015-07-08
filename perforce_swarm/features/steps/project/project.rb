require Rails.root.join('features', 'steps', 'project', 'project')

class Spinach::Features::Project < Spinach::FeatureSteps
  step 'I should not see "Snippets" button' do
    find('.content').should_not have_link 'Snippets'
  end

  # EE only steps
  step 'I visit project "Shop" settings page' do
    page.within '.sidebar-wrapper' do
      click_link 'Settings'
    end
  end

  step 'I go to "Members"' do
    page.within '.sidebar-wrapper' do
      click_link 'Members'
    end
  end

  step 'I go to "Audit Events"' do
    page.within '.sidebar-wrapper' do
      click_link 'Audit Events'
    end
  end
end
