require Rails.root.join('features', 'steps', 'profile', 'profile')

class Spinach::Features::Profile < Spinach::FeatureSteps
  step 'I click on my profile picture' do
    page.find(:css, 'header .profile-pic').click
    page.find(:css, 'header .profile-link').click
  end
end
