class Spinach::Features::AdminAppearance < Spinach::FeatureSteps
  step 'I should see a customized appearance' do
    # we don't include the title in the GitSwarm landing page
    expect(page).to have_content appearance.description
  end
end
