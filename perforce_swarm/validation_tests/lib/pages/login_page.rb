require_relative '../page'
require_relative 'logged_in_page'

class LoginPage < Page

  #
  # Initialize can take a url to go to.  Otherwise assums we are
  # already on a login page
  #
  def initialize(driver, url=nil)
    super(driver)
    goto(url) if url
    verify()
  end

  def elements_for_validation
    elems = super
    elems << [:id,'user_login'] # username field for login
    elems << [:id,'user_password'] # password field for login
    elems << [:class,'btn-save'] # login button
    return elems
  end

  def enter_credentials(user, password)
    @driver.find_element(:id, 'user_login').send_keys(user)
    @driver.find_element(:id, 'user_password').send_keys(password)
  end

  def click_login()
    @driver.find_element(:class, 'btn-save').click
  end

  def click_login_expecting_password_reset()
    # click login, then return a page for the password reset page
    raise 'Not implemented yet'
  end

  def click_login_expecting_dashboard()
    # click login, then return a page for the dashboard
    click_login
    return LoggedInPage.new(@driver)
  end


end