require 'yaml'
require 'P4'
require_relative '../lib/log'
require_relative '../lib/config'
require_relative '../lib/git_helper'
require_relative '../lib/git_fusion_helper'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/p4_helper'
require_relative '../lib/browser'

RSpec.configure do |config|
  config.before(:suite) do
    # Creating the tmp-clients umbrella  directory under the validation_tests/spec directory
    # This ensures that there isn't a huge proliferation of  client directories on an unknown
    # location on the host machine, while allowing for multiple test runs to remain isolated
    cleanup_tmp_dirs
    Dir.mkdir(tmp_client_dir) unless File.exist?(tmp_client_dir)
  end

  config.before(:each, browser: true) do
    @driver = Browser.driver
  end

  config.after(:each, browser: true) do
    Browser.reset!
  end
end

def tmp_client_dir
  File.join(__dir__, '..', 'tmp-clients')
end

def unique_string
  Time.new.strftime('%H%M%S%L')
end

def create_file(directory, name = unique_string)
  FileUtils.mkdir_p(directory)
  path = directory+'/'+name
  new_file = File.open(path, 'w+')
  new_file.write 'content'
  new_file.close
  path
end

def cleanup_tmp_dirs
  FileUtils.rm_rf(tmp_client_dir)
end

def run_block_with_retry(retries, seconds_between = 1, &block)
  result = false
  iteration = 0
  while !result && iteration < retries
    result = yield block if block_given?
    iteration += 1
    sleep seconds_between
  end
  result
end
