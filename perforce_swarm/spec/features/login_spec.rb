require 'spec_helper'

feature 'Login', feature: true do
  describe 'initial login after setup' do
    it 'allows the initial admin to create a password when the gitswarm user is also present' do
      # this behavior is dependent on there only one admin user and another used called 'gitswarm'
      User.delete_all

      user = create(:admin, password_automatically_set: true)
      create(:user, username: 'gitswarm')

      visit root_path
      expect(current_path).to eq edit_user_password_path
      expect(page).to have_content('Please create a password for your new account.')

      fill_in 'user_password',              with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      click_button 'Change your password'

      expect(current_path).to eq new_user_session_path
      expect(page).to have_content(I18n.t('devise.passwords.updated_not_active'))

      fill_in 'user_login',    with: user.username
      fill_in 'user_password', with: 'password'
      click_button 'Sign in'

      expect(current_path).to eq root_path
    end
  end
end
