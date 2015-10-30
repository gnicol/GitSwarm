require 'yaml'
require 'P4'
require_relative '../lib/log'
require_relative '../lib/config'
require_relative '../lib/git_helper'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/p4_helper'
require_relative '../lib/browser'

RSpec.configure do |config|
  config.before(:suite) do
    # Creating the tmp-clients umbrella  directory under the validation_tests/spec directory
    # This ensures that there isn't a huge proliferation of  client directories on an unknown
    # location on the host machine, while allowing for multiple test runs to remain isolated
    cleanup_tmp_dirs
    tmp_clients = File.join(__dir__, 'tmp-clients')
    Dir.mkdir(tmp_clients) unless File.exist?(tmp_clients)
  end

  config.before(:each, browser: true) do
    @driver = Browser.driver
  end

  config.after(:each, browser: true) do
    Browser.reset!
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

def cleanup_tmp_dirs
  FileUtils.rm_rf(File.join(__dir__, 'tmp-clients'))
end
