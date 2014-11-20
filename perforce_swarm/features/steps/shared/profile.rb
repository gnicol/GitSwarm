module SharedProfile
  include Spinach::DSL

  step 'I change the username to "NewUserQA" in \'Profile settings\'' do
    fill_in 'user_name', with: 'NewUserQA'
    click_button 'Save changes'
  end

  step 'the profile settings should be updated' do
    find(:css, '.flash-notice').should have_content('Profile was successfully updated')
  end
end
