require Rails.root.join('spec', 'support', 'login_helpers')

module LoginHelpers
  # Requires Javascript driver.
  def logout
    page.find(:css, 'header .profile-pic').click
    page.find(:css, 'header .logout').click
  end

  # Internal: Login as the specified user
  #
  # user - User instance to login with
  def login_with(user)
    visit new_user_session_path
    fill_in "user_login", with: user.email
    fill_in "user_password", with: "12345678"
    click_button "Log in"
    Thread.current[:current_user] = user
  end
end
