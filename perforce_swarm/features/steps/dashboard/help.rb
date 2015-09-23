require Rails.root.join('features', 'steps', 'dashboard', 'help')

class Spinach::Features::DashboardHelp < Spinach::FeatureSteps
  # override these steps to look for our rebranded text
  step 'I should see "Rake Tasks" page markdown rendered' do
    page.should have_content 'Gather information about GitSwarm'
  end

  step 'Header "Rebuild project satellites" should have correct ids and links' do
    header_should_have_correct_id_and_link(
      2, 'Check GitSwarm configuration', 'check-gitswarm-configuration', '.documentation'
    )
  end
end
