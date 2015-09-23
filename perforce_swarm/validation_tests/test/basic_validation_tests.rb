require 'minitest/autorun'
require 'selenium-webdriver'
require_relative '../lib/selenium_base_test'
require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'

class BasicValidationTests < SeleniumBaseTest
  def test_login_page_tile
    LOG.log(__method__)
    expected_title = 'Sign in | GitSwarm'
    LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
    assert_equal(@driver.title, expected_title, 'GitSwarm login page title wasn\'t as expected')
    LOG.log('Login page title was : ' + @driver.title)
  end

  def test_dashboard_page_tile
    LOG.log(__method__)
    expected_title = 'Dashboard | GitSwarm'
    login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
    dashboard = login.login(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
    assert_equal(@driver.title, expected_title, 'GitSwarm dashboard page title wasn\'t as expected')
    LOG.log('Dashboard page title was : ' + @driver.title)
    dashboard.logout
  end
end
