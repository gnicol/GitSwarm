class Spinach::Features::AdminAppearance < Spinach::FeatureSteps
  step 'I should see a customized appearance' do
    # note that we only have a description in gitswarm
    expect(page).to have_content appearance.description
  end
end
