require 'selenium-webdriver'

Dir['./pages/*.rb'].each {|file| require file }

class Page
  attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def goto(url)
    @driver.navigate.to url
  end

  #
  # Verify method checks that all expected elements exist on the page.
  # Calls child class method to get all expected elements, Blows up if
  # not valid.  This should be called at the ene of every child class'
  # constructor.
  #
  def verify()
    ok = true
    elements = elements_for_validation
    LOG.debug('Verifying elements : ' + elements.inspect)
    elements.each do |(by,value)|
      if @driver.find_elements(by, value).length !=1 then
        ok = false
        LOG.log("Element missing on page:  #{by} #{value}")
      end
    end
    if (!ok) then
      LOG.log('Could not find expected element(s) on page: ' +@driver.current_url)
      raise InvalidUnderlyingPageError.new('Expected element(s) not found on page.')
    end
  end

  # Method to be overridden by child classes to provide elements that should be
  # verified as on the page.  Child methods get the parent list and call super
  # to get the elements from all parent classes
  #
  def elements_for_validation
    return []
  end



end

# error class for when a page is constructed, but the page the driver is on doesn't match the expected page.
class InvalidUnderlyingPageError < StandardError

end
