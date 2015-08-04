require 'minitest/autorun'
require 'yaml'
require 'P4'
require_relative './log'

class BaseTest < Minitest::Test
  @config = nil

  def setup
    # One time only
    unless @config
      # Load Config
      LOG.info('Loading config...')
      @config = YAML.load_file('config.yml')
      LOG.log @config

      LOG.debug('Log and Suite setup complete.')

    end
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
