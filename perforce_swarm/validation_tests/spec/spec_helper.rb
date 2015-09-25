require 'yaml'
require 'P4'
require_relative '../lib/log'
require_relative '../lib/config'
require_relative '../lib/git_helper'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/p4_helper'

require 'selenium-webdriver'

module Browser
  class << self
    def driver
      @driver
    end
    def driver=(driver)
      @driver = driver
    end
  end
end

RSpec.configure do |config|
  config.before(:each, browser: true) do
    # Try to use the base headless web driver
    Browser.driver = Selenium::WebDriver.for :firefox
    @driver = Browser.driver
    # @driver = Selenium::WebDriver.for :phantomjs
  end

  config.after(:each, browser: true) do
    # do whatever here
    Browser.driver.quit
  end
end

def unique_string
  Time.new.strftime('%H%M%S%L')
end

def create_file(directory, name = unique_string)
  path = directory+'/'+name
  new_file = File.open(path, 'w+')
  new_file.write 'content'
  new_file.close
  path
end