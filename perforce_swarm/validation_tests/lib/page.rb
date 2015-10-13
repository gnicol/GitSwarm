require 'selenium-webdriver'

Dir['./pages/*.rb'].each { |file| require file }

class Page
  attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def goto(url)
    @driver.navigate.to url
  end

  def current_url
    @driver.current_url
  end

  #
  # Verify method checks that all expected elements exist on the page.
  # Calls child class method to get all expected elements, Blows up if
  # not valid.  This should be called at the ene of every child class'
  # constructor.
  #
  def verify
    ok = true
    elements = elements_for_validation
    LOG.debug('Verifying elements : ' + elements.inspect)
    elements.each do |(by, value)|
      unless page_has_element(by, value)
        ok = false
        LOG.log("Element missing on page:  #{by} #{value}")
      end
    end
    unless ok
      fail 'Could not find expected element(s) on page: ' +@driver.current_url
    end
  end

  def page_has_element(by, value)
    @driver.find_elements(by, value).length > 0
  end

  # Method to be overridden by child classes to provide elements that should be
  # verified as on the page.  Child methods get the parent list and call super
  # to get the elements from all parent classes
  #
  def elements_for_validation
    []
  end

  def wait_for(by, value, timeout = 30)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout) # seconds
    wait.until { @driver.find_element(by, value) }
  end
end
