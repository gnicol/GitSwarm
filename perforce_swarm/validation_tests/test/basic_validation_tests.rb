require 'minitest/autorun'
require 'selenium-webdriver'
require_relative '../lib/selenium_base_test'

class BasicValidationTests < SeleniumBaseTest
  def test_login_page_tile
    expected_title = 'Sign in | GitSwarm'

    @driver.navigate.to(CONFIG.get('gitswarm_url'))
    assert_equal(@driver.title, expected_title, 'GitSwarm login page title wasn\'t as expected')
    LOG.log('Login page title was : ' + @driver.title)
  end

  def test_dashboard_page_tile
    expected_title = 'Dashboard | GitSwarm'

    @driver.navigate.to(CONFIG.get('gitswarm_url'))
    @driver.find_element(id: 'user_login').send_keys(CONFIG.get('gitswarm_username'))
    @driver.find_element(id: 'user_password').send_keys(CONFIG.get('gitswarm_password'))
    @driver.find_element(class: 'btn-save').click

    assert_equal(@driver.title, expected_title, 'GitSwarm dashboard page title wasn\'t as expected')
    LOG.log('Dashboard page title was : ' + @driver.title)
  end
end
