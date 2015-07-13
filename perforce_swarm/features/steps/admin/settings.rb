require Rails.root.join('features', 'steps', 'admin', 'settings')

class Spinach::Features::AdminSettings < Spinach::FeatureSteps
  step 'I click on "Emails on push" service' do
    click_link 'Emails on push'
  end

  step 'I can see field help text like "part of the domain GitSwarm"' do
    page.should have_content 'part of the domain GitSwarm'
  end
end
