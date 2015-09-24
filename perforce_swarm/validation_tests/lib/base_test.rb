require 'minitest/autorun'
require 'yaml'
require 'P4'
require_relative './log'
require_relative './config'
require_relative '../lib/git_helper'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/p4_helper'

class BaseTest < Minitest::Test
  def setup
    LOG.log('---------------------------------------------')
  end

  def teardown
    LOG.log('---------------------------------------------')
  end

  # If we ever need to run cleanup code after all tests have run, this is the method to use
  # Minitest.after_run {
  #  LOG.debug('**** This is called only once after all tests ****')
  # }

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
end
