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

  # Minitest.after_run {
  #  LOG.debug('**** This is called only once after all tests ****')
  # }

  def now
    Time.new.strftime('%y%m%d-%H%M%S%L')
  end

  def create_file(directory, name = now)
    new_file = File.open(directory+'/'+name, 'w+')
    new_file.write 'content'
    new_file.close
    new_file
  end
end
