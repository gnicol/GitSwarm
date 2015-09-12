# EE specific test
if PerforceSwarm.ee?
  require Rails.root.join('features', 'steps', 'admin', 'license')

  class Spinach::Features::AdminLicense < Spinach::FeatureSteps
    step 'I should see a warning telling me there is no license' do
      expect(page).to have_content 'No GitSwarm Enterprise Edition license has been provided yet.'
    end
    step 'I should see a warning telling me the license has expired' do
      expect(page).to have_content 'The GitSwarm Enterprise Edition license expired'
    end
  end
end
