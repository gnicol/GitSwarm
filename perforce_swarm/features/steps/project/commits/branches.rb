require Rails.root.join('features', 'steps', 'project', 'commits', 'branches')

class Spinach::Features::ProjectCommitsBranches < Spinach::FeatureSteps
  step 'I click link "All"' do
    within '.content-wrapper' do
      click_link 'All'
    end
  end
end
