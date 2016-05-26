require 'simplecov' if ENV['SIMPLECOV']

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear_merged!
end

ENV['RAILS_ENV'] = 'test'
require './config/environment'
require 'rspec/expectations'
require 'database_cleaner'
require 'spinach/capybara'
require 'sidekiq/testing/inline'

%w(select2_helper test_env repo_helpers).each do |f|
  require Rails.root.join('spec', 'support', f)
end

Dir["#{Rails.root}/features/steps/shared/*.rb"].each { |file| require file }
Dir["#{Rails.root}/perforce_swarm/features/steps/shared/*.rb"].each { |file| require file }

WebMock.allow_net_connect!

# stub requests to updates.perforce.com for check for updates
WebMock.stub_request(:get, %r{https://updates\.perforce\.com/static/GitSwarm/GitSwarm(\-ee)?\.json})
       .to_return(status: 200, body: '{"versions":[]}', headers: {})

#
# JS driver
#
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 90, window_size: [1366, 768])
end
Capybara.default_max_wait_time  = 90
Capybara.ignore_hidden_elements = false

DatabaseCleaner.strategy = :truncation

unless ENV['CI'] || ENV['CI_SERVER']
  require 'capybara-screenshot/spinach'

  # Keep only the screenshots generated from the last failing test suite
  Capybara::Screenshot.prune_strategy = :keep_last_run
end

Spinach.hooks.before_run do
  include RSpec::Mocks::ExampleMethods
  RSpec::Mocks.setup
  TestEnv.init(mailer: false)
  TestEnv.warm_asset_cache

  # Include the test license helper if EE edition
  if PerforceSwarm.ee?
    require Rails.root.join('spec', 'support', 'license')
    TestLicense.init
  end

  include FactoryGirl::Syntax::Methods
end

Spinach.hooks.before_scenario do
  DatabaseCleaner.start
  RSpec::Mocks.setup
end

Spinach.hooks.after_scenario do
  RSpec::Mocks.verify
  RSpec::Mocks.teardown
  DatabaseCleaner.clean
end

def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop do
      active = page.evaluate_script('jQuery.active').to_i
      break if active == 0
    end
  end
rescue
  raise "AJAX request took longer than #{Capybara.default_wait_time} seconds."
end
