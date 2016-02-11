require 'selenium-webdriver'
require 'config'

# This is a subset of Capybara's own selenium driver. Enought to start it up,
# reset the session, and shut it down
module Browser
  class << self
    def driver
      unless @driver
        @driver = create_new_unmanaged_webdriver
        main = Process.pid
        at_exit do
          # Store the exit status of the test run since it goes away after calling the at_exit proc...
          @exit_status = $ERROR_INFO.status if $ERROR_INFO.is_a?(SystemExit)
          quit if Process.pid == main
          exit @exit_status if @exit_status # Force exit with stored status
        end
      end
      @driver
    end

    def create_new_unmanaged_webdriver
      browser = (CONFIG.get('browser') || 'firefox').to_sym
      new_driver = nil
      case browser
      when :phantomjs
        caps = Selenium::WebDriver::Remote::Capabilities.phantomjs
        caps['phantomjs.cli.args'] = ['--ignore-ssl-errors=true', '--web-security=false', '--ssl-protocol=any']
        new_driver = Selenium::WebDriver.for :phantomjs, desired_capabilities: caps
      else
        new_driver = Selenium::WebDriver.for browser
      end
      new_driver.manage.window.resize_to 1024, 768
      new_driver
    end

    attr_writer :driver

    # rubocop:disable Lint/HandleExceptions
    def quit
      @driver.quit if @driver
    rescue Errno::ECONNREFUSED
      # Browser must have already gone
    ensure
      @driver = nil
    end

    def reset!
      if @driver
        begin
          begin @driver.manage.delete_all_cookies
          rescue Selenium::WebDriver::Error::UnhandledError
            # delete_all_cookies fails when we've previously gone
            # to about:blank, so we rescue this error and do nothing
            # instead.
          end
          @driver.navigate.to('about:blank')
        rescue Selenium::WebDriver::Error::UnhandledAlertError
          # This error is thrown if an unhandled alert is on the page
          # Firefox appears to automatically dismiss this alert, chrome does not
          # We'll try to accept it
          begin
            @driver.switch_to.alert.accept
          rescue Selenium::WebDriver::Error::NoAlertPresentError
            # The alert is now gone - nothing to do
          end
          # try cleaning up the browser again
          retry
        end
      end
    end
  end
  # rubocop:enable Lint/HandleExceptions
end
