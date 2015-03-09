require Rails.root.join('features', 'steps', 'dashboard', 'help')

class Spinach::Features::DashboardHelp < Spinach::FeatureSteps
  # override this step to look for our rebranded text
  step 'I should see "Rake Tasks" page markdown rendered' do
    page.should have_content 'Gather information about GitSwarm and the system it runs on'
  end
end
