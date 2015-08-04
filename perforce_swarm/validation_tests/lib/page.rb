require 'selenium-webdriver'

class Page
  attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def goto(url)
    @driver.navigate.to url
  end
end
