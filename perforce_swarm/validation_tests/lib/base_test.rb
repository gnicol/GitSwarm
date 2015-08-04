require 'minitest/autorun'
require 'yaml'
require 'P4'
require_relative './log'
require_relative './config'

class BaseTest < Minitest::Test
  def setup
    LOG.log('---------------------------------------------')
  end

  def teardown
    LOG.log('---------------------------------------------')
  end

  # Minitest.after_run {
  #  LOG.debug('**** This is called only once after all tests ****')
  # }

  def now
    Time.new.strftime('%y%m%d-%H%M%S%L')
  end
end
