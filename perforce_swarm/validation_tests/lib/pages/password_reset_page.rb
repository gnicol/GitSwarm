require_relative 'logged_in_page'
require_relative '../page'

class PasswordResetPage < LoggedInPage
  def initialize(driver, url = nil)
    super(driver)
    goto(url) if url
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'user_current_password']
    elems << [:id, 'user_password']
    elems << [:id, 'user_password_confirmation']
    elems << [:name, 'commit']
    elems
  end

  # sets the password.  If no new_password is supplied, the password will be set to the old password
  # returns the login page
  def set_password(old_password, new_password = old_password)
    @driver.find_element(:id, 'user_current_password').send_keys(old_password)
    @driver.find_element(:id, 'user_password').send_keys(new_password)
    @driver.find_element(:id, 'user_password_confirmation').send_keys(new_password)
    @driver.find_element(:name, 'commit').click
    LoginPage.new(@driver)
  end
end
