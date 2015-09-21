require_relative '../page'
require_relative 'logged_in_page'

class LoggedInPage < Page

  def initialize(driver)
    super(driver)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id,'search'] # search menu
    elems << [:class,'profile-pic'] # the rop right menu
    return elems
  end


  def logout()
    @driver.find_element(:class, 'profile-pic').click
    @driver.find_element(:class, 'logout').click
    return LoginPage.new(@driver)
  end

end