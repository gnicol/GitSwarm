require Rails.root.join('features', 'steps', 'dashboard', 'group')

class Spinach::Features::DashboardGroup < Spinach::FeatureSteps
  step 'I click on the "Leave" button for group "Owned"' do
    find(:css, '.content li', text: 'Owner').find(:css, 'i.fa.fa-sign-out').click
  end

  step 'I click on the "Leave" button for group "Guest"' do
    find(:css, '.content li', text: 'Guest').find(:css, 'i.fa.fa-sign-out').click
  end

  step 'I should not see the "Leave" button for group "Owned"' do
    find(:css, '.content li', text: 'Owner').should_not have_selector(:css, 'i.fa.fa-sign-out')
  end

  step 'I should not see the "Leave" button for groupr "Guest"' do
    find(:css, '.content li', text: 'Guest').should_not have_selector(:css,  'i.fa.fa-sign-out')
  end

  step 'I should see group "Owned" in group list' do
    find(:css, '.content').should have_content('Owned')
  end

  step 'I should not see group "Owned" in group list' do
    find(:css, '.content').should_not have_content('Owned')
  end

  step 'I should see group "Guest" in group list' do
    find(:css, '.content').should have_content('Guest')
  end

  step 'I should not see group "Guest" in group list' do
    find(:css, '.content').should_not have_content('Guest')
  end
end
