require Rails.root.join('features', 'steps', 'groups')

class Spinach::Features::Groups < Spinach::FeatureSteps
  # EE only step
  step 'I go to "Audit Events"' do
    page.within '.sidebar-wrapper' do
      click_link 'Audit Events'
    end
  end
end
