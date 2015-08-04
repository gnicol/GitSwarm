require 'selenium-webdriver'
require_relative 'base_test'

class SeleniumBaseTest < BaseTest
  def setup
    super
    # Try to use the base headless web driver
    # @driver = Selenium::WebDriver.for :firefox
    @driver = Selenium::WebDriver.for :phantomjs
  end

  def teardown
    # do whatever here
    @driver.quit
    super
  end
end
