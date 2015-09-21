require_relative '../page'
require_relative 'logged_in_page'
require_relative 'password_reset_page'

class LoginPage < Page
  #
  # Initialize can take a url to go to.  Otherwise assums we are
  # already on a login page
  #
  def initialize(driver, url = nil)
    super(driver)
    goto(url) if url
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'user_login'] # username field for login
    elems << [:id, 'user_password'] # password field for login
    elems << [:class, 'btn-save'] # login button
    elems
  end

  # Logs into GitSwarm
  # if the login takes us to the page requesting password setting, this
  # method will set the password to be the same as it currently is and
  # re-login
  def login(user, password)
    enter_credentials(user, password)
    click_login
    if @driver.find_elements(:id, 'user_password_confirmation').length !=0
      # it's probably a password reset page
      password_set_page = PasswordResetPage.new(@driver)
      password_set_page.set_password(password) # set the password to be the current password
      enter_credentials(user, password)
      click_login
    end
    LoggedInPage.new(@driver)
  end

  def click_login_expecting_password_reset
    # click login, then return a page for the password reset page
    click_login
    PasswordResetPage.new(@driver)
  end

  def click_login_expecting_dashboard
    # click login, then return a page for the dashboard
    click_login
    LoggedInPage.new(@driver)
  end

  private

  def enter_credentials(user, password)
    @driver.find_element(:id, 'user_login').send_keys(user)
    @driver.find_element(:id, 'user_password').send_keys(password)
  end

  def click_login
    @driver.find_element(:class, 'btn-save').click
  end
end
