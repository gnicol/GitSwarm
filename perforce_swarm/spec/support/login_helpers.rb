require Rails.root.join('spec', 'support', 'login_helpers')

module LoginHelpers
  # Requires Javascript driver.
  def logout
    page.find(:css, 'header .profile-pic').click
    page.find(:css, 'header .logout').click
  end
end
